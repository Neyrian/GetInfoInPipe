# Import necessary .NET libraries
Add-Type -TypeDefinition @"
using System;
using System.IO;
using System.IO.Pipes;
using System.Security.Cryptography;
using System.Runtime.InteropServices;
using System.Text;

public class PipeServer
{
    private static string PipeName = "GetInfosPipe";
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
    public struct PROCESSENTRY32
    {
        public int dwSize;
        public int cntUsage;
        public int th32ProcessID;
        public IntPtr th32DefaultHeapID;
        public int th32ModuleID;
        public int cntThreads;
        public int th32ParentProcessID;
        public int pcPriClassBase;
        public int dwFlags;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 260)]
        public string szExeFile;
    }

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr CreateToolhelp32Snapshot(uint dwFlags, uint th32ProcessID);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool Process32First(IntPtr hSnapshot, ref PROCESSENTRY32 lppe);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool Process32Next(IntPtr hSnapshot, ref PROCESSENTRY32 lppe);

    [DllImport("kernel32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool CloseHandle(IntPtr hObject);

    public static void Start()
    {
        using (NamedPipeServerStream pipeServer = new NamedPipeServerStream(PipeName, PipeDirection.Out))
        {
            Console.WriteLine("[*] Named Pipe Created: " + PipeName);
            pipeServer.WaitForConnection();
            Console.WriteLine("[*] Client connected.");

            // Gather system information
            string output = ExecuteCommands();
            string encryptedData = EncryptData(output);

            // Write encrypted data to the named pipe
            using (StreamWriter writer = new StreamWriter(pipeServer))
            {
                writer.Write(encryptedData);
                writer.Flush();   // Ensure data is written
                writer.Close();   // Close writer to signal completion
            }
        }
    }

    private static string ExecuteCommands()
    {
        return RunCommand("whoami /all") + RunCommand("ipconfig /all") + RunCommand("netstat -aon") + ListProcesses();
    }

    private static string RunCommand(string command)
    {
        try
        {
            System.Diagnostics.ProcessStartInfo psi = new System.Diagnostics.ProcessStartInfo("cmd.exe", "/c " + command);
            psi.RedirectStandardOutput = true;
            psi.UseShellExecute = false;
            psi.CreateNoWindow = true;

            using (System.Diagnostics.Process process = System.Diagnostics.Process.Start(psi))
            {
                using (StreamReader reader = process.StandardOutput)
                {
                    return reader.ReadToEnd();
                }
            }
        }
        catch (Exception ex)
        {
            return "[Error] " + ex.Message;
        }
    }
    
    public static string ListProcesses()
    {
        StringBuilder sb = new StringBuilder();
        IntPtr hSnapshot = CreateToolhelp32Snapshot(0x00000002, 0);

        if (hSnapshot == IntPtr.Zero)
            return "[ERROR] Failed to create snapshot.";

        PROCESSENTRY32 procEntry = new PROCESSENTRY32();
        procEntry.dwSize = Marshal.SizeOf(typeof(PROCESSENTRY32));

        if (Process32First(hSnapshot, ref procEntry))
        {
            do
            {
                sb.AppendLine(procEntry.th32ProcessID + " - " + procEntry.szExeFile);
            }
            while (Process32Next(hSnapshot, ref procEntry));
        }

        CloseHandle(hSnapshot);
        return sb.ToString();
    }


    private static string EncryptData(string plainText)
    {
        using (Aes aes = Aes.Create())
        {
            aes.Key = Encoding.UTF8.GetBytes("0123456789ABCDEF0123456789ABCDEF"); // 256-bit key
            aes.IV = Encoding.UTF8.GetBytes("ABCDEF0123456789"); // 128-bit IV

            using (ICryptoTransform encryptor = aes.CreateEncryptor(aes.Key, aes.IV))
            {
                byte[] encrypted = encryptor.TransformFinalBlock(Encoding.UTF8.GetBytes(plainText), 0, plainText.Length);
                return Convert.ToBase64String(encrypted);
            }
        }
    }
}
"@ -Language CSharp



# Start the Named Pipe Server in a separate PowerShell process
[PipeServer]::Start()
Write-Host "[*] Named Pipe Server Started..."

exit
