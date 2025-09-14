Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# Fetch the wordlist content
$wordlistUrl = "https://raw.githubusercontent.com/v0re/dirb/refs/heads/master/wordlists/common.txt"
$wlist = (Invoke-WebRequest -Uri $wordlistUrl).Content -split "`n" | Select-Object -First 150

#$wlist | Select-Object -First 10

$proxy_socks=(cmd /c curl -sL https://cdn.jsdelivr.net/gh/proxifly/free-proxy-list@main/proxies/protocols/socks4/data.txt)+(cmd /c curl -sL https://cdn.jsdelivr.net/gh/proxifly/free-proxy-list@main/proxies/protocols/socks5/data.txt)

$form= New-Object Windows.Forms.Form
$form.text='Psh-Dirsearch'
$form.Size=New-Object System.Drawing.Point 700,700

$panel1 = New-Object Windows.Forms.panel
$panel1.Location = New-Object Drawing.Point 5,5
$panel1.Size = New-Object Drawing.Point 670,650
$panel1.BorderStyle = 'FixedSingle';
$panel1.backcolor = '#BEF2DF'
$form.controls.add($panel1)

$panel2 = New-Object Windows.Forms.panel
$panel2.Location = New-Object Drawing.Point 0,70
$panel2.Size = New-Object Drawing.Point 668,80
$panel2.BorderStyle = 'FixedSingle';
$panel2.backcolor = '#C5BEF2'
$panel1.controls.add($panel2)

$title = New-Object Windows.Forms.Label
$title.Location = New-Object Drawing.Point 200,20
$title.Size = New-Object Drawing.Point 350,50
$title.text = "Powershell Web-Dir Search"
$title.font = New-Object System.Drawing.Font("Aptos", 16)
$panel1.controls.add($title)

$label = New-Object Windows.Forms.Label
$label.Location = New-Object Drawing.Point 10,25
$label.Size = New-Object Drawing.Point 100,50
$label.text = "Enter URL "
$label.font = New-Object System.Drawing.Font("Aptos", 12)
$panel2.controls.add($label)

$urlbox = New-Object Windows.Forms.TextBox
$urlbox.Location = New-Object Drawing.Point 120,25
$urlbox.Size = New-Object Drawing.Point 400,50
$urlbox.font = New-Object System.Drawing.Font("Aptos", 12)
$panel2.controls.add($urlbox)

$btn = New-Object Windows.Forms.button
$btn.Location = New-Object Drawing.Point 540,23
$btn.Size = New-Object Drawing.Point 100,30
$btn.Text = "Proceed"
$btn.font = New-Object System.Drawing.Font("Aptos", 12)
$btn.Add_Click({
    if($urlbox.Text -and ($urlbox.text -match '\bhttps?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~\#?&\/=]*)')){
        $wlist | ForEach-Object {
            $path=$_;
            $prxy=$proxy_socks[(Get-Random -Minimum 1 -Maximum $proxy_socks.count)];
            try{
                $result=((cmd /c curl -k -s -x $prxy "$($urlbox.Text)$_" -i)[0] -split ' ')
            }catch{
                $result=@(' ---- ',' ---- ','Error')
            };
            $progressBar.Value=(100*$wlist.IndexOf($path)/($wlist.count-1));
            $form.Refresh();
            $dataGridView.Rows.Add($path,$result[1],($result[2..4] -join ' '))
        }
    }else{
        Write-Host 'Eh!'
    }
    
})
$panel2.controls.add($btn)

$panel3 = New-Object Windows.Forms.panel
$panel3.Location = New-Object Drawing.Point 0,150
$panel3.Size = New-Object Drawing.Point 668,500
$panel3.BorderStyle = 'FixedSingle';
$panel3.backcolor = '#EBF2BE'
$panel1.controls.add($panel3)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(20, 20)
$progressBar.Size = New-Object System.Drawing.Size(620, 20)
$progressBar.Minimum = 0
$progressBar.Maximum = 100
$progressBar.Value = 0
$panel3.Controls.Add($progressBar)

$dataGridView = New-Object System.Windows.Forms.DataGridView
$dataGridView.Location = New-Object System.Drawing.Point(0, 60)
$dataGridView.Size = New-Object System.Drawing.Size(666, 380)
$dataGridView.Columns.Add("Path", "Path")
$dataGridView.Columns.Add("StatusCode", "StatusCode")
$dataGridView.Columns.Add("Info", "Info")
$dataGridView.AutoSizeColumnsMode = 'Fill'
$dataGridView.font = New-Object System.Drawing.Font("Aptos", 11)
$panel3.Controls.Add($dataGridView)

$clearbtn = New-Object Windows.Forms.button
$clearbtn.Location = New-Object Drawing.Point 280,450
$clearbtn.Size = New-Object Drawing.Point 100,30
$clearbtn.Text = "Clear"
$clearbtn.font = New-Object System.Drawing.Font("Aptos", 12)
$clearbtn.Add_Click({
    $dataGridView.Rows.Clear()
    $urlbox.Clear()
    $progressBar.Value=0
})
$panel3.controls.add($clearbtn)

$form.ShowDialog()
