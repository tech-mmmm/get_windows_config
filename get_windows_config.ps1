################
# Scripts name : get_windows_config.ps1
# Usage        : ./get_windows_config.ps1
# Description  : Windows���擾�X�N���v�g
# Create       : 2022/05/22 tech-mmmm (https://tech-mmmm.blogspot.com/)
# Modify       :
################

$today = (Get-Date).ToString("yyyyMMdd-HHmmss")    # ���O�o�͓���
$file_path=".\$(hostname)_config_${today}.log"     # ���O�t�@�C����
$encode_file_path=".\$(hostname)_encode_${today}.tmp"     # ���������΍��p�ꎞ�t�@�C����
Start-Transcript -Path ${file_path}

function show_title($title){
    Write-Output "################################"
    Write-Output "${title}"
    Write-Output "################################"
    Write-Output ""
}

# �֐���: �R�}���h���s���O�擾�֐�
# ����1: ���s�R�}���h(�����̃R�}���h��$�𗘗p����ꍇ�̓G�X�P�[�v(`$)���邱��)
# ����2: list: ���X�g�ł��ׂĂ̍��ڂ�\���A list_brief: ���X�g�ňꕔ���ڂ�\���A�ȗ�: �e�[�u���\��
function get_command($command, $output_format){
    Write-Output "(command)# ${command}"
    if(${output_format} -eq "list"){
        ${command} = ${command} + "| fl *"
    }elseif(${output_format} -eq "list_brief"){
        ${command} = ${command} + "| fl"
    }else{
        ${command} = ${command} + "| ft -AutoSize -Wrap"
    }
    try{
        Invoke-Expression "${command}"
    }catch{
        Write-Output "[ERROR] �R�}���h���s�G���[�BCommand: ${command}"
    }
}

# �֐���: �ݒ�t�@�C���擾�֐�(�R�����g�A��s�폜)
# ����1: �t�@�C���p�X
function get_config($config_file){
    Write-Output "(config)# ${config_file}"
    if(Test-Path "${config_file}"){
        Get-Content ${config_file} | Where-Object { $_ -notmatch "^#" -and $_ -ne "" }
    }else{
        Write-Output "[ERROR] �t�@�C�������݂��܂���BFile name: ${config_file}"
    }
    Write-Output ""
}

# �֐���: ���W�X�g���擾�֐�(�R�����g�A��s�폜)
# ����1: �t�@�C���p�X
function get_registory($registory_path){
    Write-Output "(registory)# ${registory_path}"
    if(Test-Path "${registory_path}"){
        Get-ItemProperty ${registory_path}
    }else{
        Write-Output "[ERROR] ���W�X�g���̃p�X�����݂��܂���BFile name: ${registory_path}"
    }
    Write-Output ""
}


# ���C������
show_title "���擾�J�n $((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))"

show_title "�z�X�g���EOS�o�[�W�������"
get_command "hostname"
get_command "whoami.exe /user"; Write-Output ""
get_command "Get-WmiObject Win32_OperatingSystem | Select-Object Caption, OSArchitecture, Version, CodeSet, CountryCode, LastBootUpTime"

show_title "�n�[�h�E�F�A���"
get_command "Get-WmiObject Win32_ComputerSystem | Select-Object NumberOfProcessors, NumberOfLogicalProcessors, @{N='TotalPhysicalMemoryGB'; E={[Math]::Round(`$_.TotalPhysicalMemory/1GB, 2)}}" "list"
get_command "Get-PnpDevice | Select-Object Class, FriendlyName, Manufacturer, Status"

show_title "OS��{�ݒ�"
get_command "Get-ComputerInfo" "list"
if($null -eq (Get-WmiObject Win32_Pagefile)){
    Write-Output "(config)# ���ׂẴy�[�W���O�t�@�C���̃T�C�Y�������I�ɊǗ�����"
    Write-Output '�L��'
}else{
    Write-Output '����'
    get_command "Get-WmiObject Win32_Pagefile" "list"
}
Write-Output ""
# DebugInfoType�́A0:�����A1:���S�A2:�J�[�l���A3:�ŏ��A7:����
get_command "Get-WmiObject Win32_OSRecoveryConfiguration" "list"

show_title "�l�b�g���[�N�ݒ�"
get_command "ipconfig /all"; Write-Output ""
get_command "Get-NetAdapter" "list"
get_command "Get-NetAdapterAdvancedProperty"
get_command "Get-NetAdapterBinding"
get_command "Get-NetAdapterChecksumOffload"
get_command "Get-NetIPConfiguration" "list"
get_command "Get-NetIPAddress"
get_command "Get-NetRoute"
get_config "C:\Windows\system32\drivers\etc\hosts"
get_command "netsh int ipv4 show dynamicportrange tcp"
get_command "netsh int ipv4 show dynamicportrange udp"
get_command "netsh int ipv4 show excludedportrange tcp"
get_command "netsh int ipv4 show excludedportrange udp"
get_command "netsh winhttp show proxy"

show_title "�f�B�X�N�ݒ�"
# Windows Server 2022�ł͈�x�ڂ�Get-Disk�̕\��������Ȃ����Ƃ����邽�߁A2����s����
Get-Disk | Out-Null; get_command "Get-Disk"
get_command "Get-WmiObject Win32_DiskDrive | Select-Object Index, DeviceID, Model, @{N='SizeGB'; E={[Math]::Round(`$_.Size/1GB, 2)}}, Partitions | sort Index"
get_command "Get-WmiObject Win32_DiskPartition | Select-Object DiskIndex, Index, Name, BlockSize, Bootable, @{N='SizeGB'; E={[Math]::Round(`$_.Size/1GB, 2)}}, Type, Description | sort DiskIndex, Index"
get_command "Get-WmiObject Win32_LogicalDisk | Select-Object DeviceID, FileSystem, @{N='SizeGB'; E={[Math]::Round(`$_.Size/1GB, 2)}}, @{N='FreeSpaceGB'; E={[Math]::Round(`$_.FreeSpace/1GB, 2)}}, ProviderName, Description"
get_command "Get-WmiObject Win32_DiskDrive" "list"
get_command "Get-WmiObject Win32_DiskPartition" "list"
get_command "Get-WmiObject Win32_LogicalDisk" "list"
get_command "Get-ChildItem 'C:\' -Hidden"

show_title "���w�h���C�u�ݒ�"
get_command "Get-WmiObject Win32_CDROMDrive | Select-Object Drive, Caption, Manufacturer, MediaLoaded"

show_title "���[�U�E�O���[�v�ݒ�"
get_command "Get-LocalUser | Select-Object Name, Enabled, Description"
get_command "Get-LocalGroup | Select-Object Name, Description"

show_title "�����[�g�f�X�N�g�b�v�ݒ�"
Write-Output "(config)# ���̃R���s���[�^�ւ̃����[�g�ڑ���������"
if((Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server').fDenyTSConnections -eq 0){
    Write-Output '������'
}else{
    Write-Output '�����Ȃ�'
}
Write-Output ""

Write-Output "(config)# �l�b�g���[�N���x���F�؂Ń����[�g�f�X�N�g�b�v�����s���Ă���R���s���[�^�[����̂ݐڑ��������� (����)"
if((Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp').UserAuthentication -eq 0){
    Write-Output '����'
}else{
    Write-Output '�L��'
}
Write-Output ""

show_title "�����ݒ�"
get_command "Get-TimeZone"
# w32tm�̕��������΍�̂��߁A�ꎞ�t�@�C���ɏo�͂��Ă���\��
get_command "cmd /C 'w32tm /query /status > ${encode_file_path}'"
Get-Content "${encode_file_path}"
Remove-Item "${encode_file_path}" -Confirm:$false

show_title "OS����ݒ�"
get_command "Get-WinSystemLocale"
get_command "Get-Culture" "list"
get_command "Get-WmiObject Win32_Keyboard | Select-Object Name, Layout, Description"

show_title "�T�[�r�X�ݒ�"
get_command "Get-Service | Select-Object Name, DisplayName, Status, StartType"

show_title "�����E�@�\"
get_command "Get-WindowsFeature"

show_title "�X�V�v���O����"
get_command "Get-HotFix"

show_title "�C���X�g�[���\�t�g�E�F�A"
# ���W�X�g�����璊�o�B$�̓G�X�P�[�v���邱��(`$)
get_command "Get-ChildItem -Path('HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall','HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall') | % { Get-ItemProperty `$_.PsPath | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate }"

show_title "PowerShell���W���[��"
get_command "Get-ChildItem 'C:\Program Files\WindowsPowerShell\Modules'"

show_title "�C�x���g�r���[�A�["
# �Z�L�����e�B�C�x���g�̏��o�͂́A�u�Ǘ��҂Ŏ��s�v���K�v
get_command "Get-EventLog -List | Select-Object Log, LogDisplayName, OverflowAction, MaximumKilobytes"
get_command "Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\System' | Select-Object PrimaryModule, File, MaxSize"
get_command "Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Application' | Select-Object PrimaryModule, File, MaxSize"
get_command "Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Security' | Select-Object PrimaryModule, File, MaxSize"

show_title "Windows Defender�t�@�C�A�E�H�[��"
get_command "Get-NetFirewallProfile | Select-Object Name, Enabled"
get_command "Get-NetFirewallRule | Select-Object Name, DisplayName, Enabled"

# ���C�������I��
show_title "���擾�I�� $(date)"
Stop-Transcript
exit 0
