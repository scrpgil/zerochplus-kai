#============================================================================================================
#
#	�V�X�e���Ǘ� - �ݒ� ���W���[��
#	sys.setting.pl
#	---------------------------------------------------------------------------
#	2004.02.14 start
#
#	���낿���˂�v���X
#	2010.08.12 �ݒ荀�ڒǉ��ɂ�����
#
#============================================================================================================
package	MODULE;

use strict;
#use warnings;

#------------------------------------------------------------------------------------------------------------
#
#	�R���X�g���N�^
#	-------------------------------------------------------------------------------------
#	@param	�Ȃ�
#	@return	���W���[���I�u�W�F�N�g
#
#------------------------------------------------------------------------------------------------------------
sub new
{
	my $this = shift;
	my ($obj, @LOG);

	$obj = {
		'LOG' => \@LOG
	};
	bless $obj, $this;

	return $obj;
}

#------------------------------------------------------------------------------------------------------------
#
#	�\�����\�b�h
#	-------------------------------------------------------------------------------------
#	@param	$Sys	SYS_DATA
#	@param	$Form	FORMS
#	@param	$pSys	�Ǘ��V�X�e��
#	@return	�Ȃ�
#
#------------------------------------------------------------------------------------------------------------
sub DoPrint
{
	my $this = shift;
	my ($Sys, $Form, $pSys) = @_;
	my ($subMode, $BASE, $Page);

	require './module/admin/base.pl';
	$BASE = BASE->new;

	# �Ǘ�����o�^
	$Sys->Set('ADMIN', $pSys);

	# �Ǘ��}�X�^�I�u�W�F�N�g�̐���
	$Page		= $BASE->Create($Sys, $Form);
	$subMode	= $Form->Get('MODE_SUB');

	# ���j���[�̐ݒ�
	SetMenuList($BASE, $pSys);

	if ($subMode eq 'INFO') {														# �V�X�e�������
		PrintSystemInfo($Page, $Sys, $Form);
	}
	elsif ($subMode eq 'BASIC') {													# ��{�ݒ���
		PrintBasicSetting($Page, $Sys, $Form);
	}
	elsif ($subMode eq 'PERMISSION') {												# �p�[�~�b�V�����ݒ���
		PrintPermissionSetting($Page, $Sys, $Form);
	}
	elsif ($subMode eq 'LIMITTER') {												# ���~�b�^�ݒ���
		PrintLimitterSetting($Page, $Sys, $Form);
	}
	elsif ($subMode eq 'OTHER') {													# ���̑��ݒ���
		PrintOtherSetting($Page, $Sys, $Form);
	}
=pod
	elsif ($subMode eq 'PLUS') {													# ����v���X�I���W�i��
		PrintPlusSetting($Page, $Sys, $Form);
	}
=cut
	elsif ($subMode eq 'VIEW') {													# �\���ݒ�
		PrintPlusViewSetting($Page, $Sys, $Form);
	}
	elsif ($subMode eq 'SEC') {														# �K���ݒ�
		PrintPlusSecSetting($Page, $Sys, $Form);
	}
	elsif ($subMode eq 'PLUGIN') {													# �g���@�\�ݒ���
		PrintPluginSetting($Page, $Sys, $Form);
	}
	elsif ($subMode eq 'PLUGINCONF') {												# �g���@�\�ʐݒ�ݒ���
		PrintPluginOptionSetting($Page, $Sys, $Form);
	}
	elsif ($subMode eq 'COMPLETE') {												# �V�X�e���ݒ芮�����
		$Sys->Set('_TITLE', 'Process Complete');
		$BASE->PrintComplete('�V�X�e���ݒ菈��', $this->{'LOG'});
	}
	elsif ($subMode eq 'FALSE') {													# �V�X�e���ݒ莸�s���
		$Sys->Set('_TITLE', 'Process Failed');
		$BASE->PrintError($this->{'LOG'});
	}

	$BASE->Print($Sys->Get('_TITLE'), 1);
}

#------------------------------------------------------------------------------------------------------------
#
#	�@�\���\�b�h
#	-------------------------------------------------------------------------------------
#	@param	$Sys	SYS_DATA
#	@param	$Form	FORMS
#	@param	$pSys	�Ǘ��V�X�e��
#	@return	�Ȃ�
#
#------------------------------------------------------------------------------------------------------------
sub DoFunction
{
	my $this = shift;
	my ($Sys, $Form, $pSys) = @_;
	my ($subMode, $err);

	# �Ǘ�����o�^
	$Sys->Set('ADMIN', $pSys);

	$subMode	= $Form->Get('MODE_SUB');
	$err		= 0;

	if ($subMode eq 'BASIC') {														# ��{�ݒ�
		$err = FunctionBasicSetting($Sys, $Form, $this->{'LOG'});
	}
	elsif ($subMode eq 'PERMISSION') {												# �p�[�~�b�V�����ݒ�
		$err = FunctionPermissionSetting($Sys, $Form, $this->{'LOG'});
	}
	elsif ($subMode eq 'LIMITTER') {												# �����ݒ�
		$err = FunctionLimitterSetting($Sys, $Form, $this->{'LOG'});
	}
	elsif ($subMode eq 'OTHER') {													# ���̑��ݒ�
		$err = FunctionOtherSetting($Sys, $Form, $this->{'LOG'});
	}
=pod
	elsif ($subMode eq 'PLUS') {													# ����v���X�I���W�i��
		$err = FunctionPlusSetting($Sys, $Form, $this->{'LOG'});
	}
=cut
	elsif ($subMode eq 'VIEW') {													# �\���ݒ�
		$err = FunctionPlusViewSetting($Sys, $Form, $this->{'LOG'});
	}
	elsif ($subMode eq 'SEC') {														# �K���ݒ�
		$err = FunctionPlusSecSetting($Sys, $Form, $this->{'LOG'});
	}
	elsif ($subMode eq 'SET_PLUGIN') {												# �g���@�\���ݒ�
		$err = FunctionPluginSetting($Sys, $Form, $this->{'LOG'});
	}
	elsif ($subMode eq 'UPDATE_PLUGIN') {											# �g���@�\���X�V
		$err = FunctionPluginUpdate($Sys, $Form, $this->{'LOG'});
	}
	elsif ($subMode eq 'SET_PLUGINCONF') {											# �g���@�\�ʐݒ�ݒ�
		$err = FunctionPluginOptionSetting($Sys, $Form, $this->{'LOG'});
	}

	# �������ʕ\��
	if ($err) {
		$pSys->{'LOGGER'}->Put($Form->Get('UserName'),"SYSTEM_SETTING($subMode)", "ERROR:$err");
		push @{$this->{'LOG'}}, $err;
		$Form->Set('MODE_SUB', 'FALSE');
	}
	else {
		$pSys->{'LOGGER'}->Put($Form->Get('UserName'),"SYSTEM_SETTING($subMode)", 'COMPLETE');
		$Form->Set('MODE_SUB', 'COMPLETE');
	}
	$this->DoPrint($Sys, $Form, $pSys);
}

#------------------------------------------------------------------------------------------------------------
#
#	���j���[���X�g�ݒ�
#	-------------------------------------------------------------------------------------
#	@param	$Base	BASE
#	@return	�Ȃ�
#
#------------------------------------------------------------------------------------------------------------
sub SetMenuList
{
	my ($Base, $pSys) = @_;

	$Base->SetMenu('���', "'sys.setting','DISP','INFO'");

	# �V�X�e���Ǘ������̂�
	if ($pSys->{'SECINFO'}->IsAuthority($pSys->{'USER'}, $ZP::AUTH_SYSADMIN, '*')) {
		$Base->SetMenu('<hr>', '');
		$Base->SetMenu('��{�ݒ�', "'sys.setting','DISP','BASIC'");
		$Base->SetMenu('�p�[�~�b�V�����ݒ�', "'sys.setting','DISP','PERMISSION'");
		$Base->SetMenu('���~�b�^�ݒ�', "'sys.setting','DISP','LIMITTER'");
		$Base->SetMenu('���̑��ݒ�', "'sys.setting','DISP','OTHER'");
		$Base->SetMenu('<hr>', '');
		$Base->SetMenu('�\���ݒ�', "'sys.setting','DISP','VIEW'");
		$Base->SetMenu('�K���ݒ�', "'sys.setting','DISP','SEC'");
		$Base->SetMenu('<hr>', '');
		$Base->SetMenu('�g���@�\\�ݒ�', "'sys.setting','DISP','PLUGIN'");
	}
}

#------------------------------------------------------------------------------------------------------------
#
#	�V�X�e������ʂ̕\��
#	-------------------------------------------------------------------------------------
#	@param	$Page	�y�[�W�R���e�L�X�g
#	@param	$SYS	�V�X�e���ϐ�
#	@param	$Form	�t�H�[���ϐ�
#	@return	�Ȃ�
#
#------------------------------------------------------------------------------------------------------------
sub PrintSystemInfo
{
	my ($Page, $SYS, $Form) = @_;

	$SYS->Set('_TITLE', '0ch+ Administrator Information');

	my $zerover = $SYS->Get('VERSION');
	my $perlver = $];
	my $perlpath = $^X;
	my $filename = $ENV{'SCRIPT_FILENAME'} || $0;
	my $serverhost = $ENV{'HTTP_HOST'};
	my $servername = $ENV{'SERVER_NAME'};
	my $serversoft = $ENV{'SERVER_SOFTWARE'};
	my @checklist = (qw(
		Encode
		Time::HiRes
		Time::Local
		Socket
	), qw(
		CGI::Session
		Storable
		Digest::SHA::PurePerl
		Net::DNS::Lite
		List::MoreUtils
		LWP::UserAgent
		XML::Simple
	), qw(
		Net::DNS
	));

	my $core = {};
	eval {
		require Module::CoreList;
		$core = $Module::CoreList::version{$perlver};
	};

	$Page->Print("<br><b>0ch+ BBS - Administrator Script</b>");
	$Page->Print("<center><table border=0 cellspacing=2 width=100%>");
	$Page->Print("<tr><td colspan=2><hr></td></tr>\n");

	$Page->Print("<tr><td class=\"DetailTitle\" colspan=2>��0ch+ Information</td></tr>\n");
	$Page->Print("<tr><td class=\"DetailTitle\">Version</td><td>$zerover</td></tr>\n");

	$Page->Print("<tr><td class=\"DetailTitle\" colspan=2>��Perl Information</td></tr>\n");
	$Page->Print("<tr><td class=\"DetailTitle\">Version</td><td>$perlver</td></tr>\n");
	$Page->Print("<tr><td class=\"DetailTitle\">Perl Path</td><td>$perlpath</td></tr>\n");
	$Page->Print("<tr><td class=\"DetailTitle\">Server Software</td><td>$serversoft</td></tr>\n");
	$Page->Print("<tr><td class=\"DetailTitle\">Server Name</td><td>$servername</td></tr>\n");
	$Page->Print("<tr><td class=\"DetailTitle\">Server Host</td><td>$serverhost</td></tr>\n");
	$Page->Print("<tr><td class=\"DetailTitle\">Script Path</td><td>$filename</td></tr>\n");

	$Page->Print("<tr><td class=\"DetailTitle\" colspan=2>��Perl Packages (include perllib)</td></tr>\n");
	foreach my $pkg (@checklist) {
		my $var = eval("require $pkg;return \${${pkg}::VERSION};");
		$var = 'undefined' if ($@ || !defined $var);
		$var = "<b>$var</b>" if (!defined $core->{$pkg} || $core->{$pkg} ne $var);
		$Page->Print("<tr><td class=\"DetailTitle\">$pkg</td><td>$var</td></tr>\n");
	}

	$Page->Print("<tr><td colspan=2></td></tr>\n");
	$Page->Print("<tr><td class=\"DetailTitle\"></td><td></td></tr>\n");

	$Page->Print("<tr><td colspan=2><hr></td></tr>\n");

	$Page->Print("</table>");

}

#------------------------------------------------------------------------------------------------------------
#
#	�V�X�e����{�ݒ��ʂ̕\��
#	-------------------------------------------------------------------------------------
#	@param	$Page	�y�[�W�R���e�L�X�g
#	@param	$SYS	�V�X�e���ϐ�
#	@param	$Form	�t�H�[���ϐ�
#	@return	�Ȃ�
#
#------------------------------------------------------------------------------------------------------------
sub PrintBasicSetting
{
	my ($Page, $SYS, $Form) = @_;
	my ($server, $cgi, $bbs, $info, $data, $common);

	$SYS->Set('_TITLE', 'System Base Setting');

	$server	= $SYS->Get('SERVER');
	$cgi	= $SYS->Get('CGIPATH');
	$bbs	= $SYS->Get('BBSPATH');
	$info	= $SYS->Get('INFO');
	$data	= $SYS->Get('DATA');

	$common = "onclick=\"DoSubmit('sys.setting','FUNC','BASIC');\"";
	if ($server eq '') {
		my $sname = $ENV{'SERVER_NAME'};
		$server = "http://$sname";
	}
	if ($cgi eq '') {
		my $path = $ENV{'SCRIPT_NAME'};
		$path =~ s|/[^/]+/[^/]+$||;
		$cgi = "$path$cgi";
	}

	$Page->Print("<center><table border=0 cellspacing=2 width=100%>");
	$Page->Print("<tr><td colspan=2>�e���ڂ�ݒ肵��[�ݒ�]�{�^���������Ă��������B<br>\n");
	$Page->Print("�������̗�������܂��B<br>\n");
	$Page->Print("�@��1: http://example.jp/test/admin.cgi<br>\n");
	$Page->Print("�@��2: http://example.net/~user/test/admin.cgi<br>\n");
	$Page->Print("�@��3: http://example.com/cgi-bin/test/admin.cgi</td></tr>\n");
	$Page->Print("<tr><td colspan=2><hr></td></tr>\n");
	$Page->Print("<tr><td class=\"DetailTitle\">�ғ��T�[�o(������ / �͗v��܂���)<br><span class=\"NormalStyle\">");
	$Page->Print("�@��1: http://example.jp<br>");
	$Page->Print("�@��2: http://example.net</span></td>");
	$Page->Print("<td><input type=text size=60 name=SERVER value=\"$server\" ></td></tr>\n");
	$Page->Print("<tr><td class=\"DetailTitle\">CGI�ݒu�f�B���N�g��(��΃p�X)<br><span class=\"NormalStyle\">");
	$Page->Print("�@��1: /test<br>");
	$Page->Print("�@��2: /~user/test<br>");
	$Page->Print("�@��3: /cgi-bin/test</span></td>");
	$Page->Print("<td><input type=text size=60 name=CGIPATH value=\"$cgi\" ></td></tr>\n");
	$Page->Print("<tr><td class=\"DetailTitle\">�f���z�u�f�B���N�g��(���΃p�X)<br><span class=\"NormalStyle\">");
	$Page->Print("�@��1: .jp/bbs1/ �� <span class=\"UnderLine\">..</span><br>");
	$Page->Print("�@��2: .net/~user/bbs2/ �� <span class=\"UnderLine\">..</span><br>");
	$Page->Print("�@��3: .com/bbs3/ �� <span class=\"UnderLine\">../..</span></span></td>");
	$Page->Print("<td><input type=text size=60 name=BBSPATH value=\"$bbs\" ></td></tr>\n");
	$Page->Print("<tr><td class=\"DetailTitle\">�V�X�e�����f�B���N�g��(/ ����n�߂�)<br><span class=\"NormalStyle\">");
	$Page->Print("�@��1: .jp/test/info �� <span class=\"UnderLine\">/info</span><br>");
	$Page->Print("<td><input type=text size=60 name=INFO value=\"$info\" ></td></tr>\n");
	$Page->Print("<tr><td class=\"DetailTitle\">�V�X�e���f�[�^�f�B���N�g��(/ ����n�߂�)<br><span class=\"NormalStyle\">");
	$Page->Print("�@��1: .jp/test/info �� <span class=\"UnderLine\">/datas</span><br>");
	$Page->Print("<td><input type=text size=60 name=DATA value=\"$data\" ></td></tr>\n");
	$Page->Print("<tr><td colspan=2><hr></td></tr>\n");
	$Page->Print("<tr><td colspan=2 align=left>");
	$Page->Print("<input type=button value=\"�@�ݒ�@\" $common></td></tr>\n");
	$Page->Print("</table>");
}

#------------------------------------------------------------------------------------------------------------
#
#	�p�[�~�b�V�����ݒ��ʂ̕\��
#	-------------------------------------------------------------------------------------
#	@param	$Page	�y�[�W�R���e�L�X�g
#	@param	$SYS	�V�X�e���ϐ�
#	@param	$Form	�t�H�[���ϐ�
#	@return	�Ȃ�
#
#------------------------------------------------------------------------------------------------------------
sub PrintPermissionSetting
{
	my ($Page, $Sys, $Form) = @_;

	$Sys->Set('_TITLE', 'System Permission Setting');

	my $datP	= sprintf("%o", $Sys->Get('PM-DAT'));
	my $txtP	= sprintf("%o", $Sys->Get('PM-TXT'));
	my $logP	= sprintf("%o", $Sys->Get('PM-LOG'));
	my $admP	= sprintf("%o", $Sys->Get('PM-ADM'));
	my $stopP	= sprintf("%o", $Sys->Get('PM-STOP'));
	my $admDP	= sprintf("%o", $Sys->Get('PM-ADIR'));
	my $bbsDP	= sprintf("%o", $Sys->Get('PM-BDIR'));
	my $logDP	= sprintf("%o", $Sys->Get('PM-LDIR'));
	my $kakoDP	= sprintf("%o", $Sys->Get('PM-KDIR'));

	my $common = "onclick=\"DoSubmit('sys.setting','FUNC','PERMISSION');\"";

	$Page->Print("<center><table border=0 cellspacing=2 width=100%>");
	$Page->Print("<tr><td colspan=2>�e���ڂ�ݒ肵��[�ݒ�]�{�^���������Ă��������B<br>");
	$Page->Print("<b>�i8�i�l�Őݒ肷�邱�Ɓj</b></td></tr>\n");
	$Page->Print("<tr><td colspan=2><hr></td></tr>\n");

	$Page->Print("<tr><td class=\"DetailTitle\">dat�t�@�C���p�[�~�b�V����</td>");
	$Page->Print("<td><input type=text size=10 name=PERM_DAT value=\"$datP\" ></td></tr>\n");
	$Page->Print("<tr><td class=\"DetailTitle\">�e�L�X�g�t�@�C���p�[�~�b�V����</td>");
	$Page->Print("<td><input type=text size=10 name=PERM_TXT value=\"$txtP\" ></td></tr>\n");
	$Page->Print("<tr><td class=\"DetailTitle\">���O�t�@�C���p�[�~�b�V����</td>");
	$Page->Print("<td><input type=text size=10 name=PERM_LOG value=\"$logP\" ></td></tr>\n");
	$Page->Print("<tr><td class=\"DetailTitle\">�Ǘ��t�@�C���p�[�~�b�V����</td>");
	$Page->Print("<td><input type=text size=10 name=PERM_ADMIN value=\"$admP\" ></td></tr>\n");
	$Page->Print("<tr><td class=\"DetailTitle\">��~�X���b�h�t�@�C���p�[�~�b�V����</td>");
	$Page->Print("<td><input type=text size=10 name=PERM_STOP value=\"$stopP\" ></td></tr>\n");
	$Page->Print("<tr><td class=\"DetailTitle\">�Ǘ��f�B���N�g���p�[�~�b�V����</td>");
	$Page->Print("<td><input type=text size=10 name=PERM_ADMIN_DIR value=\"$admDP\" ></td></tr>\n");
	$Page->Print("<tr><td class=\"DetailTitle\">�f���f�B���N�g���p�[�~�b�V����</td>");
	$Page->Print("<td><input type=text size=10 name=PERM_BBS_DIR value=\"$bbsDP\" ></td></tr>\n");
	$Page->Print("<tr><td class=\"DetailTitle\">���O�ۑ��f�B���N�g���p�[�~�b�V����</td>");
	$Page->Print("<td><input type=text size=10 name=PERM_LOG_DIR value=\"$logDP\" ></td></tr>\n");
	$Page->Print("<tr><td class=\"DetailTitle\">�ߋ����O�q�Ƀf�B���N�g���p�[�~�b�V����</td>");
	$Page->Print("<td><input type=text size=10 name=PERM_KAKO_DIR value=\"$kakoDP\" ></td></tr>\n");

	$Page->Print("<tr><td colspan=2><hr></td></tr>\n");
	$Page->Print("<tr><td colspan=2 align=left>");
	$Page->Print("<input type=button value=\"�@�ݒ�@\" $common></td></tr>\n");
	$Page->Print("</table>");
}

#------------------------------------------------------------------------------------------------------------
#
#	�����ݒ��ʂ̕\��
#	-------------------------------------------------------------------------------------
#	@param	$Page	�y�[�W�R���e�L�X�g
#	@param	$SYS	�V�X�e���ϐ�
#	@param	$Form	�t�H�[���ϐ�
#	@return	�Ȃ�
#
#	2010.08.12 windyakin ��
#	 -> �V�X�e���ύX�ɔ����ݒ荀�ڂ̒ǉ�
#
#------------------------------------------------------------------------------------------------------------
sub PrintLimitterSetting
{
	my ($Page, $SYS, $Form) = @_;
	my (@vSYS, $common);

	$SYS->Set('_TITLE', 'System Limitter Setting');

	$common = "onclick=\"DoSubmit('sys.setting','FUNC','LIMITTER');\"";
	$vSYS[0] = $SYS->Get('RESMAX');
	$vSYS[1] = $SYS->Get('SUBMAX');
	$vSYS[2] = $SYS->Get('ANKERS');
	$vSYS[3] = $SYS->Get('ERRMAX');
	$vSYS[4] = $SYS->Get('HSTMAX');
	$vSYS[5] = $SYS->Get('ADMMAX');

	$Page->Print("<center><table border=0 cellspacing=2 width=100%>");
	$Page->Print("<tr><td colspan=2>�e���ڂ�ݒ肵��[�ݒ�]�{�^���������Ă��������B</td></tr>");
	$Page->Print("<tr><td colspan=2><hr></td></tr>\n");

	$Page->Print("<tr><td class=\"DetailTitle\">1�f����subject�ő�ێ���</td>");
	$Page->Print("<td><input type=text size=10 name=SUBMAX value=\"$vSYS[1]\" ></td></tr>\n");
	$Page->Print("<tr><td class=\"DetailTitle\">1�X���b�h�̃��X�ő吔</td>");
	$Page->Print("<td><input type=text size=10 name=RESMAX value=\"$vSYS[0]\" ></td></tr>\n");
	$Page->Print("<tr><td class=\"DetailTitle\">1���X�̃A���J�[�ő吔(0�Ŗ�����)</td>");
	$Page->Print("<td><input type=text size=10 name=ANKERS value=\"$vSYS[2]\" ></td></tr>\n");
	$Page->Print("<tr><td class=\"DetailTitle\">�G���[���O�ő�ێ���</td>");
	$Page->Print("<td><input type=text size=10 name=ERRMAX value=\"$vSYS[3]\" ></td></tr>\n");
	$Page->Print("<tr><td class=\"DetailTitle\">�z�X�g���O�ő�ێ���</td>");
	$Page->Print("<td><input type=text size=10 name=HSTMAX value=\"$vSYS[4]\" ></td></tr>\n");
	$Page->Print("<tr><td class=\"DetailTitle\">�Ǘ����샍�O�ő�ێ���</td>");
	$Page->Print("<td><input type=text size=10 name=ADMMAX value=\"$vSYS[5]\" ></td></tr>\n");

	$Page->Print("<tr><td colspan=2><hr></td></tr>\n");
	$Page->Print("<tr><td colspan=2 align=left>");
	$Page->Print("<input type=button value=\"�@�ݒ�@\" $common></td></tr>\n");
	$Page->Print("</table>");
}

#------------------------------------------------------------------------------------------------------------
#
#	���̑��ݒ��ʂ̕\��
#	-------------------------------------------------------------------------------------
#	@param	$Page	�y�[�W�R���e�L�X�g
#	@param	$SYS	�V�X�e���ϐ�
#	@param	$Form	�t�H�[���ϐ�
#	@return	�Ȃ�
#
#------------------------------------------------------------------------------------------------------------
sub PrintOtherSetting
{
	my ($Page, $SYS, $Form) = @_;
	my ($urlLink, $linkSt, $linkEd, $pathKind, $headText, $headUrl, $FastMode, $BBSGET, $upCheck);
	my ($linkChk, $pathInfo, $pathQuery, $fastMode, $bbsget);
	my ($common);

	$SYS->Set('_TITLE', 'System Other Setting');

	$urlLink	= $SYS->Get('URLLINK');
	$linkSt		= $SYS->Get('LINKST');
	$linkEd		= $SYS->Get('LINKED');
	$pathKind	= $SYS->Get('PATHKIND');
	$headText	= $SYS->Get('HEADTEXT');
	$headUrl	= $SYS->Get('HEADURL');
	$FastMode	= $SYS->Get('FASTMODE');
	$BBSGET		= $SYS->Get('BBSGET');
	$upCheck	= $SYS->Get('UPCHECK');

	$linkChk	= ($urlLink eq 'TRUE' ? 'checked' : '');
	$fastMode	= ($FastMode == 1 ? 'checked' : '');
	$pathInfo	= ($pathKind == 0 ? 'checked' : '');
	$pathQuery	= ($pathKind == 1 ? 'checked' : '');
	$bbsget		= ($BBSGET == 1 ? 'checked' : '');

	$common = "onclick=\"DoSubmit('sys.setting','FUNC','OTHER');\"";

	$Page->Print("<center><table border=0 cellspacing=2 width=100%>");
	$Page->Print("<tr><td colspan=2>�e���ڂ�ݒ肵��[�ݒ�]�{�^���������Ă��������B</td></tr>");
	$Page->Print("<tr><td colspan=2><hr></td></tr>\n");

	$Page->Print("<tr bgcolor=silver><td colspan=2 class=\"DetailTitle\">�w�b�_�֘A</td></tr>\n");
	$Page->Print("<tr><td>�w�b�_�����ɕ\\������e�L�X�g</td>");
	$Page->Print("<td><input type=text size=60 name=HEADTEXT value=\"$headText\" ></td></tr>\n");
	$Page->Print("<tr><td>��L�e�L�X�g�ɓ\\�郊���N��URL</td>");
	$Page->Print("<td><input type=text size=60 name=HEADURL value=\"$headUrl\" ></td></tr>\n");

	$Page->Print("<tr bgcolor=silver><td colspan=2 class=\"DetailTitle\">�{������URL</td></tr>\n");
	$Page->Print("<tr><td colspan=2><input type=checkbox name=URLLINK $linkChk value=on>");
	$Page->Print("�{����URL�ւ̎��������N</td>");
	$Page->Print("<tr><td colspan=2><b>�ȉ����������NOFF���̂ݗL��</b></td></tr>\n");
	$Page->Print("<tr><td>�@�@�����N�֎~���ԑ�</td>");
	$Page->Print("<td><input type=text size=2 name=LINKST value=\"$linkSt\" >�� �` ");
	$Page->Print("<input type=text size=2 name=LINKED value=\"$linkEd\" >��</td></tr>\n");

	$Page->Print("<tr bgcolor=silver><td colspan=2 class=\"DetailTitle\">���샂�[�h(read.cgi)</td></tr>\n");
	$Page->Print("<tr><td>PATH���</td>");
	$Page->Print("<td><input type=radio name=PATHKIND value=\"0\" $pathInfo>PATHINFO�@");
	$Page->Print("<input type=radio name=PATHKIND value=\"1\" $pathQuery>QUERYSTRING</td></tr>\n");

	$Page->Print("<tr><td colspan=2><input type=checkbox name=FASTMODE $fastMode value=on>");
	$Page->Print("�������ݎ���index.html���X�V���Ȃ�(�����������݃��[�h)</td>");

	$Page->Print("<tr bgcolor=silver><td colspan=2 class=\"DetailTitle\">bbs.cgi��GET���\\�b�h</td></tr>\n");
	$Page->Print("<tr><td>bbs.cgi��GET���\\�b�h���g�p����</td>");
	$Page->Print("<td><input type=checkbox name=BBSGET $bbsget value=on></td></tr>\n");

	$Page->Print("<tr bgcolor=silver><td colspan=2 class=\"DetailTitle\">�X�V�`�F�b�N�֘A</td></tr>\n");
	$Page->Print("<tr><td>�X�V�`�F�b�N�̊Ԋu</td>");
	$Page->Print("<td><input type=text size=2 name=UPCHECK value=\"$upCheck\">��(0�Ń`�F�b�N����)</td></tr>\n");

	$Page->Print("<tr><td colspan=2><hr></td></tr>\n");
	$Page->Print("<tr><td colspan=2 align=left>");
	$Page->Print("<input type=button value=\"�@�ݒ�@\" $common></td></tr>\n");

	$Page->Print("</table>");

}

#------------------------------------------------------------------------------------------------------------
#
#	�\���ݒ��ʂ̕\��(���낿���˂�v���X�I���W�i��)
#	-------------------------------------------------------------------------------------
#	@param	$Page	�y�[�W�R���e�L�X�g
#	@param	$SYS	�V�X�e���ϐ�
#	@param	$Form	�t�H�[���ϐ�
#	@return	�Ȃ�
#
#	2010.09.08 windyakin ��
#	 -> �\���ݒ�ƋK���ݒ�̕���
#
#------------------------------------------------------------------------------------------------------------
sub PrintPlusViewSetting
{
	my ($Page, $SYS, $Form) = @_;

	$SYS->Set('_TITLE', 'System View Setting');

	my $Banner		= $SYS->Get('BANNER');
	my $Counter		= $SYS->Get('COUNTER');
	my $Prtext		= $SYS->Get('PRTEXT');
	my $Prlink		= $SYS->Get('PRLINK');
	my $Msec		= $SYS->Get('MSEC');

	my $bannerindex	= ($Banner & 3 ? 'checked' : '');
	my $banner		= ($Banner & 5 ? 'checked' : '');
	my $msec		= ($Msec == 1 ? 'checked' : '');

	my $common = "onclick=\"DoSubmit('sys.setting','FUNC','VIEW');\"";

	$Page->Print("<center><table border=0 cellspacing=2 width=100%>");
	$Page->Print("<tr><td colspan=2>�e���ڂ�ݒ肵��[�ݒ�]�{�^���������Ă��������B</td></tr>");
	$Page->Print("<tr><td colspan=2><hr></td></tr>\n");

	$Page->Print("<tr bgcolor=silver><td colspan=2 class=\"DetailTitle\">Read.cgi�֘A</td></tr>\n");
	$Page->Print("<tr><td>ofuda.cc�̃A�J�E���g������� <small>(�����͂ŃJ�E���^�[��\\��)</small></td>");
	$Page->Print("<td><input type=text size=60 name=COUNTER value=\"$Counter\"></td></tr>\n");
	$Page->Print("<tr><td>PR���̕\\�������� <small>(�����͂�PR����\\��)</small></td>");
	$Page->Print("<td><input type=text size=60 name=PRTEXT value=\"$Prtext\"></td></tr>\n");
	$Page->Print("<tr><td>PR���̃����NURL</td>");
	$Page->Print("<td><input type=text size=60 name=PRLINK value=\"$Prlink\"></td></tr>\n");

	$Page->Print("<tr bgcolor=silver><td colspan=2 class=\"DetailTitle\">���m���\\��</td></tr>\n");
	$Page->Print("<tr><td>index.html�̍��m����\\������</td>");
	$Page->Print("<td><input type=checkbox name=BANNERINDEX $bannerindex value=on></td></tr>\n");
	$Page->Print("<tr><td>index.html�ȊO�̍��m����\\������</td>");
	$Page->Print("<td><input type=checkbox name=BANNER $banner value=on></td></tr>\n");

	$Page->Print("<tr bgcolor=silver><td colspan=2 class=\"DetailTitle\">msec�\\��</td></tr>\n");
	$Page->Print("<tr><td>�~���b�܂ŕ\\������</small></td>");
	$Page->Print("<td><input type=checkbox name=MSEC $msec value=on></td></tr>\n");

	$Page->Print("<tr><td colspan=2><hr></td></tr>\n");
	$Page->Print("<tr><td colspan=2 align=left>");
	$Page->Print("<input type=button value=\"�@�ݒ�@\" $common></td></tr>\n");
	$Page->Print("</table>");

}

#------------------------------------------------------------------------------------------------------------
#
#	�K���ݒ��ʂ̕\��(���낿���˂�v���X�I���W�i��)
#	-------------------------------------------------------------------------------------
#	@param	$Page	�y�[�W�R���e�L�X�g
#	@param	$SYS	�V�X�e���ϐ�
#	@param	$Form	�t�H�[���ϐ�
#	@return	�Ȃ�
#
#	2010.09.08 windyakin ��
#	 -> �\���ݒ�ƋK���ݒ�̕���
#
#------------------------------------------------------------------------------------------------------------
sub PrintPlusSecSetting
{

	my ($Page, $SYS, $Form) = @_;
	my ($Kakiko, $Samba, $DefSamba, $DefHoushi, $Trip12, $BBQ, $BBX);
	my ($kakiko, $trip12, $bbq, $bbx);
	my ($common);

	$SYS->Set('_TITLE', 'System Regulation Setting');

	$Kakiko		= $SYS->Get('KAKIKO');
	$Samba		= $SYS->Get('SAMBATM');
	$DefSamba	= $SYS->Get('DEFSAMBA');
	$DefHoushi	= $SYS->Get('DEFHOUSHI');
	$Trip12		= $SYS->Get('TRIP12');
	$BBQ		= $SYS->Get('BBQ');
	$BBX		= $SYS->Get('BBX');

	$kakiko		= ($Kakiko == 1 ? 'checked' : '');
	$trip12		= ($Trip12 == 1 ? 'checked' : '');
	$bbq		= ($BBQ == 1 ? 'checked' : '');
	$bbx		= ($BBX == 1 ? 'checked' : '');

	$common = "onclick=\"DoSubmit('sys.setting','FUNC','SEC');\"";

	$Page->Print("<center><table border=0 cellspacing=2 width=100%>");
	$Page->Print("<tr><td colspan=2>�e���ڂ�ݒ肵��[�ݒ�]�{�^���������Ă��������B</td></tr>");
	$Page->Print("<tr><td colspan=2><hr></td></tr>\n");

	$Page->Print("<tr bgcolor=silver><td colspan=2 class=\"DetailTitle\">�Q�d�������ł����H�H</td></tr>\n");
	$Page->Print("<tr><td>����IP����̏������݂̕��������ω����Ȃ��ꍇ�K������</td>");
	$Page->Print("<td><input type=checkbox name=KAKIKO $kakiko value=on></td></tr>\n");

	$Page->Print("<tr bgcolor=silver><td colspan=2 class=\"DetailTitle\">�Z���ԓ��e�K��</td></tr>\n");
	$Page->Print("<tr><td>�Z���ԓ��e�K���b�������(0�ŋK������)</td>");
	$Page->Print("<td><input type=text size=60 name=SAMBATM value=\"$Samba\"></td></tr>\n");

	$Page->Print("<tr bgcolor=silver><td colspan=2 class=\"DetailTitle\">Samba�K��</td></tr>\n");
	$Page->Print("<tr><td>Samba�ҋ@�b���f�t�H���g�l�����(0�ŋK������)<br>");
	$Page->Print("<small>Samba�̐ݒ�͌f�����Ƃɐݒ�ł��܂�</small></td>");
	$Page->Print("<td><input type=text size=60  name=DEFSAMBA value=\"$DefSamba\"></td></tr>\n");
	$Page->Print("<tr><td>Samba��d����(��)�f�t�H���g�l�����</td>");
	$Page->Print("<td><input type=text size=60 name=DEFHOUSHI value=\"$DefHoushi\"></td></tr>\n");

	$Page->Print("<tr bgcolor=silver><td colspan=2 class=\"DetailTitle\">�V�d�l�g���b�v</td></tr>\n");
	$Page->Print("<tr><td>�V�d�l�g���b�v(12��=SHA-1)��L���ɂ���</td>");
	$Page->Print("<td><input type=checkbox name=TRIP12 $trip12 value=on></td></tr>\n");

	$Page->Print("<tr bgcolor=silver><td colspan=2 class=\"DetailTitle\">DNSBL�ݒ�</td></tr>\n");
	$Page->Print("<tr><td colspan=2>�K�p����DNSBL�Ƀ`�F�b�N������Ă�������<br>\n");
	$Page->Print("<input type=checkbox name=BBQ $bbq value=on>");
	$Page->Print("<a href=\"http://bbq.uso800.net/\" target=\"_blank\">BBQ</a>\n");
	$Page->Print("<input type=checkbox name=BBX $bbx value=on>BBX\n");
	$Page->Print("</td></tr>\n");

	$Page->Print("<tr><td colspan=2><hr></td></tr>\n");
	$Page->Print("<tr><td colspan=2 align=left>");
	$Page->Print("<input type=button value=\"�@�ݒ�@\" $common></td></tr>\n");
	$Page->Print("</table>");

}

#------------------------------------------------------------------------------------------------------------
#
#	�g���@�\�ݒ��ʂ̕\��
#	-------------------------------------------------------------------------------------
#	@param	$Page	�y�[�W�R���e�L�X�g
#	@param	$SYS	�V�X�e���ϐ�
#	@param	$Form	�t�H�[���ϐ�
#	@return	�Ȃ�
#
#------------------------------------------------------------------------------------------------------------
sub PrintPluginSetting
{
	my ($Page, $SYS, $Form) = @_;
	my (@pluginSet, $num, $common, $Plugin);

	$SYS->Set('_TITLE', 'System Plugin Setting');
	$common = "onclick=\"DoSubmit('sys.setting','FUNC'";

	require './module/plugins.pl';
	$Plugin = PLUGINS->new;
	$Plugin->Load($SYS);
	$num = $Plugin->GetKeySet('ALL', '', \@pluginSet);

	# �g���@�\�����݂���ꍇ�͗L���E�����ݒ��ʂ�\��
	if ($num > 0) {
		my ($id, $file, $class, $name, $expl, $valid);

		$Page->Print("<center><table border=0 cellspacing=2 width=100%>");
		$Page->Print("<tr><td colspan=5>�L���ɂ���@�\\�Ƀ`�F�b�N�����Ă��������B</td></tr>\n");
		$Page->Print("<tr><td colspan=5><hr></td></tr>\n");
		$Page->Print("<tr>");
		$Page->Print("<td class=\"DetailTitle\">Order</td>");
		$Page->Print("<td class=\"DetailTitle\">Function Name</td>");
		$Page->Print("<td class=\"DetailTitle\">Explanation</td>");
		$Page->Print("<td class=\"DetailTitle\">File</td>");
		$Page->Print("<td class=\"DetailTitle\">Options</td></tr>\n");

		for my $i (0 .. $#pluginSet) {
			$id = $pluginSet[$i];
			$file = $Plugin->Get('FILE', $id);
			$class = $Plugin->Get('CLASS', $id);
			$name = $Plugin->Get('NAME', $id);
			$expl = $Plugin->Get('EXPL', $id);
			$valid = $Plugin->Get('VALID', $id) == 1 ? 'checked' : '';
			$Page->Print("<tr><td><input type=text name=PLUGIN_${id}_ORDER value=@{[$i+1]} size=3></td>");
			$Page->Print("<td><input type=checkbox name=PLUGIN_VALID value=$id $valid> $name</td>");
			$Page->Print("<td>$expl</td><td>$file</td>");
			if ($class->can('getConfig') && scalar(keys %{$class->getConfig()}) > 0) {
				$Page->Print("<td><a href=\"javascript:SetOption('PLGID','$id');");
				$Page->Print("DoSubmit('sys.setting','DISP','PLUGINCONF');\">�ʐݒ�</a></td>");
			}
			else {
				$Page->Print("<td></td>");
			}
			$Page->Print("</tr>\n");
		}
		$Page->Print("<tr><td colspan=5><hr></td></tr>\n");
		$Page->Print("<tr><td colspan=5 align=left>");
		$Page->Print("<input type=button value=\"�@�ݒ�@\" $common,'SET_PLUGIN');\"> ");
	}
	else {
		$Page->Print("<center><table border=0 cellspacing=2 width=100%>");
		$Page->Print("<tr><td><hr></td></tr>\n");
		$Page->Print("<tr><td><b>�v���O�C���͑��݂��܂���B</b></td></tr>\n");
		$Page->Print("<tr><td><hr></td></tr>\n");
		$Page->Print("<tr><td align=left>");
	}
		$Page->Print("<input type=hidden name=PLGID value=\"\">");
		$Page->Print("<input type=button value=\"�@�X�V�@\" $common,'UPDATE_PLUGIN');\">");
	$Page->Print("</td></tr>");
	$Page->Print("</table>");
}

#------------------------------------------------------------------------------------------------------------
#
#	�g���@�\�ʐݒ�ݒ��ʂ̕\��
#	-------------------------------------------------------------------------------------
#	@param	$Page	�y�[�W�R���e�L�X�g
#	@param	$SYS	�V�X�e���ϐ�
#	@param	$Form	�t�H�[���ϐ�
#	@return	�Ȃ�
#
#------------------------------------------------------------------------------------------------------------
sub PrintPluginOptionSetting
{
	my ($Page, $SYS, $Form) = @_;
	my ($common, $Plugin, $Config, %conftype);
	my ($id, $file, $className, $conf);

	$id = $Form->Get('PLGID');

	require './module/plugins.pl';
	$Plugin = PLUGINS->new;
	$Plugin->Load($SYS);
	$Config = PLUGINCONF->new($Plugin, $id);

	$SYS->Set('_TITLE', 'System Plugin Option Setting - ' . $Plugin->Get('NAME', $id));
	$common = "onclick=\"DoSubmit('sys.setting','FUNC'";

	$file = $Plugin->Get('FILE', $id);
	require "./plugin/$file";
	$file =~ /^0ch_(.*)\.pl$/;
	$className = "ZPL_$1";
	if ($className->can('getConfig')) {
		my $plugin = $className->new;
		$conf = $plugin->getConfig();
	}

	$Page->Print("<center><table border=0 cellspacing=2 width=100%>");
	$Page->Print("<tr><td colspan=4>�ʐݒ�</td></tr>\n");
	$Page->Print("<tr><td colspan=4><hr></td></tr>\n");
	$Page->Print("<tr>");
	$Page->Print("<td class=\"DetailTitle\">Name</td>");
	$Page->Print("<td class=\"DetailTitle\">Value</td>");
	$Page->Print("<td class=\"DetailTitle\" width=50%>Explanation</td>");
	$Page->Print("<td class=\"DetailTitle\">Type</td></tr>\n");

	%conftype = (
		1	=>	'���l',
		2	=>	'������',
		3	=>	'�^�U�l',
	);

	if (defined $conf) {
		foreach my $key (sort keys %$conf) {
			my ($val, $type, $desc);
			$val = $Config->GetConfig($key);
			$type = $conf->{$key}->{'valuetype'};
			$desc = $conf->{$key}->{'description'};

			$val =~ s/([\"<>\x5c])/\x5c$1/g if ($type eq 2);

			$Page->Print("<tr><td>$key</td>");
			if ($type eq 3) {
				$Page->Print("<td><input type=checkbox name=PLUGIN_OPT_@{[unpack('H*', $key)]}@{[$val ? ' checked' : '']}></td>");
			}
			else {
				$Page->Print("<td><input type=text name=PLUGIN_OPT_@{[unpack('H*', $key)]} value=\"$val\" size=30></td>");
			}
			$Page->Print("<td>$desc</td><td>$conftype{$type}</td></tr>\n");
		}
	}

	$Page->Print("<tr><td colspan=4><hr></td></tr>\n");
	$Page->Print("<tr><td colspan=4 align=left>");
	$Page->Print("<input type=hidden name=PLGID value=\"$id\">");
	$Page->Print("<input type=button value=\"�@�ݒ�@\" $common,'SET_PLUGINCONF');\">");

	$Page->Print("</td></tr>");
	$Page->Print("</table>");
}

#------------------------------------------------------------------------------------------------------------
#
#	�g���@�\�ʐݒ�ݒ�
#	-------------------------------------------------------------------------------------
#	@param	$Sys	�V�X�e���ϐ�
#	@param	$Form	�t�H�[���ϐ�
#	@param	$pLog	���O�p
#	@return	�G���[�R�[�h
#
#------------------------------------------------------------------------------------------------------------
sub FunctionPluginOptionSetting
{
	my ($Sys, $Form, $pLog) = @_;
	my ($common, $Plugin, $Config, %conftype);
	my ($id, $file, $className, $plugin, $conf);

	# �����`�F�b�N
	{
		my $SEC = $Sys->Get('ADMIN')->{'SECINFO'};
		my $chkID = $Sys->Get('ADMIN')->{'USER'};

		if (($SEC->IsAuthority($chkID, $ZP::AUTH_SYSADMIN, '*')) == 0) {
			return 1000;
		}
	}

	$id = $Form->Get('PLGID');

	require './module/plugins.pl';
	$Plugin = PLUGINS->new;
	$Plugin->Load($Sys);
	$Config = PLUGINCONF->new($Plugin, $id);

	$file = $Plugin->Get('FILE', $id);
	require "./plugin/$file";
	$file =~ /^0ch_(.*)\.pl$/;
	$className = "ZPL_$1";
	$plugin = new $className;
	if ($className->can('getConfig')) {
		$conf = $plugin->getConfig();
	}

	if (defined $conf) {
		push @$pLog, "$className";
		foreach my $key (sort keys %$conf) {
			my ($val);
			$val = $Form->Get('PLUGIN_OPT_' . unpack('H*', $key));
			$Config->SetConfig($key, $val);
			push @$pLog, "$key ��ݒ肵�܂����B";
		}
	}

	return 0;
}

#------------------------------------------------------------------------------------------------------------
#
#	��{�ݒ�
#	-------------------------------------------------------------------------------------
#	@param	$Sys	�V�X�e���ϐ�
#	@param	$Form	�t�H�[���ϐ�
#	@param	$pLog	���O�p
#	@return	�G���[�R�[�h
#
#------------------------------------------------------------------------------------------------------------
sub FunctionBasicSetting
{
	my ($Sys, $Form, $pLog) = @_;
	my ($SYSTEM);

	# �����`�F�b�N
	{
		my $SEC = $Sys->Get('ADMIN')->{'SECINFO'};
		my $chkID = $Sys->Get('ADMIN')->{'USER'};

		if (($SEC->IsAuthority($chkID, $ZP::AUTH_SYSADMIN, '*')) == 0) {
			return 1000;
		}
	}
	# ���̓`�F�b�N
	{
		my @inList = ('SERVER', 'CGIPATH', 'BBSPATH', 'INFO', 'DATA');
		if (! $Form->IsInput(\@inList)) {
			return 1001;
		}
	}
	require './module/sys_data.pl';
	$SYSTEM = SYS_DATA->new;
	$SYSTEM->Init();

	$SYSTEM->Set('SERVER', $Form->Get('SERVER'));
	$SYSTEM->Set('CGIPATH', $Form->Get('CGIPATH'));
	$SYSTEM->Set('BBSPATH', $Form->Get('BBSPATH'));
	$SYSTEM->Set('INFO', $Form->Get('INFO'));
	$SYSTEM->Set('DATA', $Form->Get('DATA'));

	$SYSTEM->Save();

	# ���O�̐ݒ�
	{
		push @$pLog, '�� ��{�ݒ�';
		push @$pLog, '�@�@�@ �T�[�o�F' . $Form->Get('SERVER');
		push @$pLog, '�@�@�@ CGI�p�X�F' . $Form->Get('CGIPATH');
		push @$pLog, '�@�@�@ �f���p�X�F' . $Form->Get('BBSPATH');
		push @$pLog, '�@�@�@ �Ǘ��f�[�^�t�H���_�F' . $Form->Get('INFO');
		push @$pLog, '�@�@�@ ��{�f�[�^�t�H���_�F' . $Form->Get('DATA');
	}
	return 0;
}

#------------------------------------------------------------------------------------------------------------
#
#	�p�[�~�b�V�����ݒ�
#	-------------------------------------------------------------------------------------
#	@param	$Sys	�V�X�e���ϐ�
#	@param	$Form	�t�H�[���ϐ�
#	@param	$pLog	���O�p
#	@return	�G���[�R�[�h
#
#------------------------------------------------------------------------------------------------------------
sub FunctionPermissionSetting
{
	my ($Sys, $Form, $pLog) = @_;
	my ($SYSTEM);

	# �����`�F�b�N
	{
		my $SEC = $Sys->Get('ADMIN')->{'SECINFO'};
		my $chkID = $Sys->Get('ADMIN')->{'USER'};

		if (($SEC->IsAuthority($chkID, $ZP::AUTH_SYSADMIN, '*')) == 0) {
			return 1000;
		}
	}
	require './module/sys_data.pl';
	$SYSTEM = SYS_DATA->new;
	$SYSTEM->Init();

	$SYSTEM->Set('PM-DAT', oct($Form->Get('PERM_DAT')));
	$SYSTEM->Set('PM-TXT', oct($Form->Get('PERM_TXT')));
	$SYSTEM->Set('PM-LOG', oct($Form->Get('PERM_LOG')));
	$SYSTEM->Set('PM-ADM', oct($Form->Get('PERM_ADMIN')));
	$SYSTEM->Set('PM-STOP', oct($Form->Get('PERM_STOP')));
	$SYSTEM->Set('PM-ADIR', oct($Form->Get('PERM_ADMIN_DIR')));
	$SYSTEM->Set('PM-BDIR', oct($Form->Get('PERM_BBS_DIR')));
	$SYSTEM->Set('PM-LDIR', oct($Form->Get('PERM_LOG_DIR')));
	$SYSTEM->Set('PM-KDIR', oct($Form->Get('PERM_KAKO_DIR')));

	$SYSTEM->Save();

	# ���O�̐ݒ�
	{
		push @$pLog, '�� ��{�ݒ�';
		push @$pLog, '�@�@�@ dat�p�[�~�b�V�����F' . $Form->Get('PERM_DAT');
		push @$pLog, '�@�@�@ txt�p�[�~�b�V�����F' . $Form->Get('PERM_TXT');
		push @$pLog, '�@�@�@ log�p�[�~�b�V�����F' . $Form->Get('PERM_LOG');
		push @$pLog, '�@�@�@ �Ǘ��t�@�C���p�[�~�b�V�����F' . $Form->Get('PERM_ADMIN');
		push @$pLog, '�@�@�@ ��~�X���b�h�p�[�~�b�V�����F' . $Form->Get('PERM_STOP');
		push @$pLog, '�@�@�@ �Ǘ�DIR�p�[�~�b�V�����F' . $Form->Get('PERM_ADMIN_DIR');
		push @$pLog, '�@�@�@ �f����DIR�p�[�~�b�V�����F' . $Form->Get('PERM_BBS_DIR');
		push @$pLog, '�@�@�@ ���ODIR�p�[�~�b�V�����F' . $Form->Get('PERM_LOG_DIR');
		push @$pLog, '�@�@�@ �q��DIR�p�[�~�b�V�����F' . $Form->Get('PERM_KAKO_DIR');
	}
	return 0;
}

#------------------------------------------------------------------------------------------------------------
#
#	�����l�ݒ�
#	-------------------------------------------------------------------------------------
#	@param	$Sys	�V�X�e���ϐ�
#	@param	$Form	�t�H�[���ϐ�
#	@param	$pLog	���O�p
#	@return	�G���[�R�[�h
#
#------------------------------------------------------------------------------------------------------------
sub FunctionLimitterSetting
{
	my ($Sys, $Form, $pLog) = @_;
	my ($SYSTEM);

	# �����`�F�b�N
	{
		my $SEC	= $Sys->Get('ADMIN')->{'SECINFO'};
		my $chkID = $Sys->Get('ADMIN')->{'USER'};

		if (($SEC->IsAuthority($chkID, $ZP::AUTH_SYSADMIN, '*')) == 0) {
			return 1000;
		}
	}
	require './module/sys_data.pl';
	$SYSTEM = SYS_DATA->new;
	$SYSTEM->Init();

	$SYSTEM->Set('RESMAX', $Form->Get('RESMAX'));
	$SYSTEM->Set('SUBMAX', $Form->Get('SUBMAX'));
	$SYSTEM->Set('ANKERS', $Form->Get('ANKERS'));
	$SYSTEM->Set('ERRMAX', $Form->Get('ERRMAX'));
	$SYSTEM->Set('HSTMAX', $Form->Get('HSTMAX'));
	$SYSTEM->Set('ADMMAX', $Form->Get('ADMMAX'));

	$SYSTEM->Save();

	# ���O�̐ݒ�
	{
		push @$pLog, '�� ��{�ݒ�';
		push @$pLog, '�@�@�@ subject�ő吔�F' . $Form->Get('SUBMAX');
		push @$pLog, '�@�@�@ ���X�ő吔�F' . $Form->Get('RESMAX');
		push @$pLog, '�@�@�@ �A���J�[�ő吔�F' . $Form->Get('ANKERS');
		push @$pLog, '�@�@�@ �G���[���O�ő吔�F' . $Form->Get('ERRMAX');
		push @$pLog, '�@�@�@ �z�X�g���O�ő吔�F' . $Form->Get('HSTMAX');
		push @$pLog, '�@�@�@ �Ǘ����샍�O�ő吔�F' . $Form->Get('ADMMAX');
	}
	return 0;
}

#------------------------------------------------------------------------------------------------------------
#
#	���̑��ݒ�
#	-------------------------------------------------------------------------------------
#	@param	$Sys	�V�X�e���ϐ�
#	@param	$Form	�t�H�[���ϐ�
#	@param	$pLog	���O�p
#	@return	�G���[�R�[�h
#
#------------------------------------------------------------------------------------------------------------
sub FunctionOtherSetting
{
	my ($Sys, $Form, $pLog) = @_;
	my ($SYSTEM);

	# �����`�F�b�N
	{
		my $SEC = $Sys->Get('ADMIN')->{'SECINFO'};
		my $chkID = $Sys->Get('ADMIN')->{'USER'};

		if (($SEC->IsAuthority($chkID, $ZP::AUTH_SYSADMIN, '*')) == 0) {
			return 1000;
		}
	}
	require './module/sys_data.pl';
	$SYSTEM = SYS_DATA->new;
	$SYSTEM->Init();

	$SYSTEM->Set('HEADTEXT', $Form->Get('HEADTEXT'));
	$SYSTEM->Set('HEADURL', $Form->Get('HEADURL'));
	$SYSTEM->Set('URLLINK', ($Form->Equal('URLLINK', 'on') ? 'TRUE' : 'FALSE'));
	$SYSTEM->Set('LINKST', $Form->Get('LINKST'));
	$SYSTEM->Set('LINKED', $Form->Get('LINKED'));
	$SYSTEM->Set('PATHKIND', $Form->Get('PATHKIND'));
	$SYSTEM->Set('FASTMODE', ($Form->Equal('FASTMODE', 'on') ? 1 : 0));
	$SYSTEM->Set('BBSGET', ($Form->Equal('BBSGET', 'on') ? 1 : 0));
	$SYSTEM->Set('UPCHECK', $Form->Get('UPCHECK'));

	$SYSTEM->Save();

	# ���O�̐ݒ�
	{
		push @$pLog, '�� ���̑��ݒ�';
		push @$pLog, '�@�@�@ �w�b�_�e�L�X�g�F' . $SYSTEM->Get('HEADTEXT');
		push @$pLog, '�@�@�@ �w�b�_URL�F' . $SYSTEM->Get('HEADURL');
		push @$pLog, '�@�@�@ URL���������N�F' . $SYSTEM->Get('URLLINK');
		push @$pLog, '�@�@�@ �@�J�n���ԁF' . $SYSTEM->Get('LINKST');
		push @$pLog, '�@�@�@ �@�I�����ԁF' . $SYSTEM->Get('LINKED');
		push @$pLog, '�@�@�@ PATH��ʁF' . $SYSTEM->Get('PATHKIND');
		push @$pLog, '�@�@�@ index.html���X�V���Ȃ��F' . $SYSTEM->Get('FASTMODE');
		push @$pLog, '�@�@�@ bbs.cgi��GET���\\�b�h�F' . $SYSTEM->Get('BBSGET');
		push @$pLog, '�@�@�@ �X�V�`�F�b�N�Ԋu�F' . $SYSTEM->Get('UPCHECK');
	}
	return 0;
}

#------------------------------------------------------------------------------------------------------------
#
#	�\���ݒ�(���낿���˂�v���X�I���W�i��)
#	-------------------------------------------------------------------------------------
#	@param	$Sys	�V�X�e���ϐ�
#	@param	$Form	�t�H�[���ϐ�
#	@param	$pLog	���O�p
#	@return	�G���[�R�[�h
#
#	2010.09.08 windyakin ��
#	 -> �\���ݒ�ƋK���ݒ�̕���
#
#------------------------------------------------------------------------------------------------------------
sub FunctionPlusViewSetting
{
	my ($Sys, $Form, $pLog) = @_;
	my ($SYSTEM);

	# �����`�F�b�N
	{
		my $SEC = $Sys->Get('ADMIN')->{'SECINFO'};
		my $chkID = $Sys->Get('ADMIN')->{'USER'};

		if (($SEC->IsAuthority($chkID, $ZP::AUTH_SYSADMIN, '*')) == 0) {
			return 1000;
		}
	}
	require './module/sys_data.pl';
	$SYSTEM = SYS_DATA->new;
	$SYSTEM->Init();

	$SYSTEM->Set('COUNTER', $Form->Get('COUNTER'));
	$SYSTEM->Set('PRTEXT', $Form->Get('PRTEXT'));
	$SYSTEM->Set('PRLINK', $Form->Get('PRLINK'));
	my $banner = ($Form->Equal('BANNERINDEX', 'on')?2:0) | ($Form->Equal('BANNER', 'on')?4:0);
	$SYSTEM->Set('BANNER', $banner);
	$SYSTEM->Set('MSEC', ($Form->Equal('MSEC', 'on') ? 1 : 0));

	$SYSTEM->Save();

	# ���O�̐ݒ�
	{
		push @$pLog, '�@�@�@ �J�E���^�[�A�J�E���g�F' . $SYSTEM->Get('COUNTER');
		push @$pLog, '�@�@�@ PR���\\��������F' . $SYSTEM->Get('PRTEXT');
		push @$pLog, '�@�@�@ PR�������NURL�F' . $SYSTEM->Get('PRLINK');
		push @$pLog, '�@�@�@ �o�i�[�\\���F' . $SYSTEM->Get('BANNER');
		push @$pLog, '�@�@�@ �~���b�\���F' . $SYSTEM->Get('MSEC');
	}
	return 0;
}

#------------------------------------------------------------------------------------------------------------
#
#	�K���ݒ�(���낿���˂�v���X�I���W�i��)
#	-------------------------------------------------------------------------------------
#	@param	$Sys	�V�X�e���ϐ�
#	@param	$Form	�t�H�[���ϐ�
#	@param	$pLog	���O�p
#	@return	�G���[�R�[�h
#
#	2010.09.08 windyakin ��
#	 -> �\���ݒ�ƋK���ݒ�̕���
#
#------------------------------------------------------------------------------------------------------------
sub FunctionPlusSecSetting
{
	my ($Sys, $Form, $pLog) = @_;
	my ($SYSTEM);

	# �����`�F�b�N
	{
		my $SEC = $Sys->Get('ADMIN')->{'SECINFO'};
		my $chkID = $Sys->Get('ADMIN')->{'USER'};

		if (($SEC->IsAuthority($chkID, $ZP::AUTH_SYSADMIN, '*')) == 0) {
			return 1000;
		}
	}
	require './module/sys_data.pl';
	$SYSTEM = SYS_DATA->new;
	$SYSTEM->Init();

	$SYSTEM->Set('KAKIKO', ($Form->Equal('KAKIKO', 'on') ? 1 : 0));
	$SYSTEM->Set('SAMBATM', $Form->Get('SAMBATM'));
	$SYSTEM->Set('DEFSAMBA', $Form->Get('DEFSAMBA'));
	$SYSTEM->Set('DEFHOUSHI', $Form->Get('DEFHOUSHI'));
	$SYSTEM->Set('TRIP12', ($Form->Equal('TRIP12', 'on') ? 1 : 0));
	$SYSTEM->Set('BBQ', ($Form->Equal('BBQ', 'on') ? 1 : 0));
	$SYSTEM->Set('BBX', ($Form->Equal('BBX', 'on') ? 1 : 0));

	$SYSTEM->Save();

	{
		push @$pLog, '�@�@�@ 2�d�J�L�R�K���F' . $SYSTEM->Get('KAKIKO');
		push @$pLog, '�@�@�@ �A�����e�K���b���F' . $SYSTEM->Get('SAMBATM');
		push @$pLog, '�@�@�@ Samba�ҋ@�b���F' . $SYSTEM->Get('DEFSAMBA');
		push @$pLog, '�@�@�@ Samba��d���ԁF' . $SYSTEM->Get('DEFHOUSHI');
		push @$pLog, '�@�@�@ 12���g���b�v�F' . $SYSTEM->Get('TRIP12');
		push @$pLog, '�@�@�@ BBQ�F' . $SYSTEM->Get('BBQ');
		push @$pLog, '�@�@�@ BBX�F' . $SYSTEM->Get('BBX');
	}
	return 0;
}

#------------------------------------------------------------------------------------------------------------
#
#	�v���O�C�����ݒ�
#	-------------------------------------------------------------------------------------
#	@param	$Sys	�V�X�e���ϐ�
#	@param	$Form	�t�H�[���ϐ�
#	@param	$pLog	���O�p
#	@return	�G���[�R�[�h
#
#------------------------------------------------------------------------------------------------------------
sub FunctionPluginSetting
{
	my ($Sys, $Form, $pLog) = @_;
	my ($Plugin);

	# �����`�F�b�N
	{
		my $SEC = $Sys->Get('ADMIN')->{'SECINFO'};
		my $chkID = $Sys->Get('ADMIN')->{'USER'};

		if (($SEC->IsAuthority($chkID, $ZP::AUTH_SYSADMIN, '*')) == 0) {
			return 1000;
		}
	}
	require './module/plugins.pl';
	$Plugin = PLUGINS->new;
	$Plugin->Load($Sys);

	my (@pluginSet, @validSet, %order);

	$Plugin->GetKeySet('ALL', '', \@pluginSet);
	@validSet = $Form->GetAtArray('PLUGIN_VALID');

	for my $i (0 .. $#pluginSet) {
		my $id = $pluginSet[$i];
		my $valid = 0;
		foreach (@validSet) {
			if ($_ eq $id) {
				$valid = 1;
				last;
			}
		}
		push @$pLog, $Plugin->Get('NAME', $id) . ' ��' . ($valid ? '�L��' : '����') . '�ɐݒ肵�܂����B';
		$Plugin->Set($id, 'VALID', $valid);

		$_ = $Form->Get("PLUGIN_${id}_ORDER", $i + 1);
		$_ = $i + 1 if ($_ ne ($_ - 0));
		$_ -= 0;
		$order{$_} = [] if (! exists $order{$_});
		push @{$order{$_}}, $id;
	}
	$Plugin->{'ORDER'} = [];
	push @{$Plugin->{'ORDER'}}, @{$order{$_}} foreach (sort {$a <=> $b} keys %order);
	$Plugin->Save($Sys);

	return 0;
}

#------------------------------------------------------------------------------------------------------------
#
#	�v���O�C�����X�V
#	-------------------------------------------------------------------------------------
#	@param	$Sys	�V�X�e���ϐ�
#	@param	$Form	�t�H�[���ϐ�
#	@param	$pLog	���O�p
#	@return	�G���[�R�[�h
#
#------------------------------------------------------------------------------------------------------------
sub FunctionPluginUpdate
{
	my ($Sys, $Form, $pLog) = @_;
	my ($Plugin);

	# �����`�F�b�N
	{
		my $SEC = $Sys->Get('ADMIN')->{'SECINFO'};
		my $chkID = $Sys->Get('ADMIN')->{'USER'};

		if (($SEC->IsAuthority($chkID, $ZP::AUTH_SYSADMIN, '*')) == 0) {
			return 1000;
		}
	}
	require './module/plugins.pl';
	$Plugin = PLUGINS->new;

	# ���̍X�V�ƕۑ�
	$Plugin->Load($Sys);
	$Plugin->Update();
	$Plugin->Save($Sys);

	# ���O�̐ݒ�
	{
		push @$pLog, '�� �v���O�C�����̍X�V';
		push @$pLog, '�@�v���O�C�����̍X�V���������܂����B';
	}
	return 0;
}

#============================================================================================================
#	Module END
#============================================================================================================
1;