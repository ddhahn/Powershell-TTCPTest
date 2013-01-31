##run ttcp and create an output file from stderr.

#cd c:
#cd \windows\ttcp
cd g:
cd \tools\ttcp
$toollocation = "g:\tools\ttcp"
#$toollocation = "c:\windows\ttcp"
cd $toollocation

$logfile = "results.csv"
$testserver = "servername"
$args = "-t -f m -l 51200 " + $testserver
$execpath = $PWD.ToString() + "\pcattcp.exe"
$computername = get-content env:computername

## create a process object and set some of the parameters
$processobj = New-Object System.Diagnostics.Process
$processobj.StartInfo.FileName = $execpath
$processobj.StartInfo.Arguments = $args
$processobj.StartInfo.UseShellExecute=$false
$processobj.StartInfo.RedirectStandardError=$true
$processobj.StartInfo.CreateNoWindow=$true
$processobj.StartInfo.WindowStyle=[System.Diagnostics.ProcessWindowStyle]::Hidden
$processobj.Start()

## read the output from standard error. pcattcp writes to stderr instead of stdout
$output = $processobj.StandardError.ReadToEnd()

## wait for the process to exit.
$processobj.WaitForExit()

## parse the output for the information we want
## 10 will have the bytes, seconds and rate

$parsed = $output.Split("`n")
## delims defines the delimters we'll use to parse the string 
$delims = @(" bytes in "," real seconds = ")
$info_to_log = $parsed[10].Split($delims,[System.StringSplitOptions]::RemoveEmptyEntries)
## fix up the poutput
$info_to_log[2] = $info_to_log[2].Replace(" Mbit/sec +++", "")
##$info_to_log[0] = bytes transferred
##$info_to_log[1] = time elapsed
##$info_to_log[2] = mbit\second
$nowdate = (date).tostring()

$logstring = $nowdate + "," + $computername + "," + $testserver + "," + $info_to_log[0] + "," + $info_to_log[1] + "," + $info_to_log[2].TrimEnd()

Out-File -FilePath $logfile -InputObject $logstring -Append -Encoding ASCII