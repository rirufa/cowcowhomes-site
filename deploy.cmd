@call hexo clean
@call hexo g
"C:\Program Files (x86)\WinSCP\WinSCP.exe" %FTP_SERVER_HOST% /synchronize .\public /
.\gdrive-windows-x64.exe sync upload .\source\image\ 1gMOz4dX75PRZ4E1DyHftNw7xGZOKIO3w