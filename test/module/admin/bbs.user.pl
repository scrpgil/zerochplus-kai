#============================================================================================================
#
#	�f���Ǘ� - �Ǘ��O���[�v ���W���[��
#	bbs.user.pl
#	---------------------------------------------------------------------------
#	2004.07.10 start
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
	my ($subMode, $BASE, $BBS, $Page);

	require './module/admin/base.pl';
	$BASE = BASE->new;
	$BBS = $pSys->{'AD_BBS'};

	# �f�����̓ǂݍ��݂ƃO���[�v�ݒ�
	if (! defined $BBS) {
		require './module/bbs_manage.pl';
		$BBS = BBS_MANAGE->new;

		$BBS->Load($Sys);
		$Sys->Set('BBS', $BBS->Get('DIR', $Form->Get('TARGET_BBS')));
		$pSys->{'SECINFO'}->SetGroupInfo($BBS->Get('DIR', $Form->Get('TARGET_BBS')));
	}

	# �Ǘ��}�X�^�I�u�W�F�N�g�̐���
	$Page		= $BASE->Create($Sys, $Form);
	$subMode	= $Form->Get('MODE_SUB');

	# ���j���[�̐ݒ�
	SetMenuList($BASE, $pSys, $Sys->Get('BBS'));

	if ($subMode eq 'LIST') {														# �O���[�v�ꗗ���
		PrintGroupList($Page, $Sys, $Form);
	}
	elsif ($subMode eq 'CREATE') {													# �O���[�v�쐬���
		PrintGroupSetting($Page, $Sys, $Form, 0);
	}
	elsif ($subMode eq 'EDIT') {													# �O���[�v�ҏW���
		PrintGroupSetting($Page, $Sys, $Form, 1);
	}
	elsif ($subMode eq 'DELETE') {													# �O���[�v�폜�m�F���
		PrintGroupDelete($Page, $Sys, $Form);
	}
	elsif ($subMode eq 'IMPORT') {													# �O���[�v�C���|�[�g���
		PrintGroupImport($Page, $Sys, $Form, $BBS);
	}
	elsif ($subMode eq 'COMPLETE') {												# �O���[�v�ݒ芮�����
		$Sys->Set('_TITLE', 'Process Complete');
		$BASE->PrintComplete('�Ǘ��O���[�v����', $this->{'LOG'});
	}
	elsif ($subMode eq 'FALSE') {													# �O���[�v�ݒ莸�s���
		$Sys->Set('_TITLE', 'Process Failed');
		$BASE->PrintError($this->{'LOG'});
	}

	# �f������ݒ�
	$Page->HTMLInput('hidden', 'TARGET_BBS', $Form->Get('TARGET_BBS'));

	$BASE->Print($Sys->Get('_TITLE') . ' - ' . $BBS->Get('NAME', $Form->Get('TARGET_BBS')), 2);
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
	my ($subMode, $err, $BBS);

	require './module/bbs_manage.pl';
	$BBS = BBS_MANAGE->new;

	# �Ǘ�����o�^
	$BBS->Load($Sys);
	$Sys->Set('BBS', $BBS->Get('DIR', $Form->Get('TARGET_BBS')));
	$pSys->{'SECINFO'}->SetGroupInfo($Sys->Get('BBS'));

	$subMode	= $Form->Get('MODE_SUB');
	$err		= 9999;

	if ($subMode eq 'CREATE') {													# �O���[�v�쐬
		$err = FunctionGroupSetting($Sys, $Form, 0, $this->{'LOG'});
	}
	elsif ($subMode eq 'EDIT') {													# �O���[�v�ҏW
		$err = FunctionGroupSetting($Sys, $Form, 1, $this->{'LOG'});
	}
	elsif ($subMode eq 'DELETE') {													# �O���[�v�폜
		$err = FunctionGroupDelete($Sys, $Form, $this->{'LOG'});
	}
	elsif ($subMode eq 'IMPORT') {													# �O���[�v�C���|�[�g
		$err = FunctionGroupImport($Sys, $Form, $this->{'LOG'}, $BBS);
	}

	# �������ʕ\��
	if ($err) {
		$pSys->{'LOGGER'}->Put($Form->Get('UserName'),"USER_GROUP($subMode)", "ERROR:$err");
		push @{$this->{'LOG'}}, $err;
		$Form->Set('MODE_SUB', 'FALSE');
	}
	else {
		$pSys->{'LOGGER'}->Put($Form->Get('UserName'),"USER_GROUP($subMode)", 'COMPLETE');
		$Form->Set('MODE_SUB', 'COMPLETE');
	}
	$pSys->{'AD_BBS'} = $BBS;
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
	my ($Base, $pSys, $bbs) = @_;

	$Base->SetMenu('�O���[�v�ꗗ', "'bbs.user','DISP','LIST'");

	# �Ǘ��O���[�v�ݒ茠���̂�
	if ($pSys->{'SECINFO'}->IsAuthority($pSys->{'USER'}, $ZP::AUTH_USERGROUP, $bbs)) {
		$Base->SetMenu('�O���[�v�o�^', "'bbs.user','DISP','CREATE'");
		$Base->SetMenu('�O���[�v�C���|�[�g', "'bbs.user','DISP','IMPORT'");
	}
	$Base->SetMenu('<hr>', '');
	$Base->SetMenu('�V�X�e���Ǘ��֖߂�', "'sys.bbs','DISP','LIST'");
}

#------------------------------------------------------------------------------------------------------------
#
#	�O���[�v�ꗗ�̕\��
#	-------------------------------------------------------------------------------------
#	@param	$Page	�y�[�W�R���e�L�X�g
#	@param	$SYS	�V�X�e���ϐ�
#	@param	$Form	�t�H�[���ϐ�
#	@return	�Ȃ�
#
#------------------------------------------------------------------------------------------------------------
sub PrintGroupList
{
	my ($Page, $Sys, $Form) = @_;
	my ($Group, $BBS, @groupSet, @user, $name, $expl, $id, $common, $isAuth, $n);

	$Sys->Set('_TITLE', 'Group List');

	require './module/sys_security.pl';
	$Group = GILDOR->new;

	# �O���[�v���̓ǂݍ���
	$Group->Load($Sys);
	$Group->GetKeySet(\@groupSet);

	$Page->Print("<center><table border=0 cellspacing=2 width=100%>");
	$Page->Print("<tr><td colspan=4><hr></td></tr>\n");
	$Page->Print("<tr><td style=\"width:30\">�@</td>");
	$Page->Print("<td class=\"DetailTitle\" style=\"width:150\">Group Name</td>");
	$Page->Print("<td class=\"DetailTitle\" style=\"width:200\">Subscription</td>");
	$Page->Print("<td class=\"DetailTitle\" style=\"width:30\">Users</td></tr>\n");

	# �����擾
	$isAuth = $Sys->Get('ADMIN')->{'SECINFO'}->IsAuthority($Sys->Get('ADMIN')->{'USER'}, $ZP::AUTH_USERGROUP, $Sys->Get('BBS'));

	# �O���[�v�ꗗ���o��
	foreach $id (@groupSet) {
		$name = $Group->Get('NAME', $id, '');
		$expl = $Group->Get('EXPL', $id, '');
		@user = split(/\, ?/, $Group->Get('USERS', $id, ''));
		$n = @user;

		$common = "\"javascript:SetOption('SELECT_GROUP','$id');";
		$common .= "DoSubmit('bbs.user','DISP','EDIT')\"";

		# �����ɂ���ĕ\����}��
		$Page->Print("<tr><td><input type=checkbox name=GROUPS value=$id></td>");
		if ($isAuth) {
			$Page->Print("<td><a href=$common>$name</a></td><td>$expl</td><td>$n</td></tr>\n");
		}
		else {
			$Page->Print("<td>$name</td><td>$expl</td><td>$n</td></tr>\n");
		}
	}
	$Page->HTMLInput('hidden', 'SELECT_GROUP', '');
	$Page->Print("<tr><td colspan=4><hr></td></tr>\n");

	# �����ɂ���ĕ\����}��
	if ($isAuth) {
		$common = "onclick=\"DoSubmit('bbs.user','DISP'";
		$Page->Print("<tr><td colspan=4 align=left>");
		$Page->Print("<input type=button value=\"�@�폜�@\" $common,'DELETE')\" class=\"delete\">");
		$Page->Print("</td></tr>\n");
	}
	$Page->Print("</table>");
}

#------------------------------------------------------------------------------------------------------------
#
#	�O���[�v�ݒ�̕\��
#	-------------------------------------------------------------------------------------
#	@param	$Page	�y�[�W�R���e�L�X�g
#	@param	$SYS	�V�X�e���ϐ�
#	@param	$Form	�t�H�[���ϐ�
#	@param	$mode	�쐬�̏ꍇ:0, �ҏW�̏ꍇ:1
#	@return	�Ȃ�
#
#------------------------------------------------------------------------------------------------------------
sub PrintGroupSetting
{
	my ($Page, $Sys, $Form, $mode) = @_;
	my ($Group, $User, @userSet, @authNum, $i, $num, $id);
	my ($name, $expl, @auth, @user, $common);

	$Sys->Set('_TITLE', 'Group Edit')	if ($mode == 1);
	$Sys->Set('_TITLE', 'Group Create')	if ($mode == 0);

	require './module/sys_security.pl';
	$User = SYS_SECURITY->new;
	$Group = GILDOR->new;

	# ���[�U���̓ǂݍ���
	$User->Load($Sys);
	$Group->Load($Sys);
	$User->GetKeySet('ALL', '', \@userSet);

	# �ҏW���[�h�Ȃ烆�[�U�����擾����
	if ($mode) {
		$name = $Group->Get('NAME', $Form->Get('SELECT_GROUP', ''), '');
		$expl = $Group->Get('EXPL', $Form->Get('SELECT_GROUP', ''), '');
		@auth = split(/\, ?/, $Group->Get('AUTH', $Form->Get('SELECT_GROUP', ''), ''));
		@user = split(/\, ?/, $Group->Get('USERS', $Form->Get('SELECT_GROUP', ''), ''));

		# �����ԍ��}�b�s���O�z����쐬
		for ($i = 0 ; $i < 15 ; $i++) {
			$authNum[$i] = '';
		}
		foreach $num (@auth) {
			$authNum[$num - 1] = 'checked';
		}
	}
	else {
		$name = '';
		$expl = '';
		@auth = ();
		@user = ();
		$Form->Set('SELECT_GROUP', '');
		for ($i = 0 ; $i < 15 ; $i++) {
			$authNum[$i] = '';
		}
	}

	$Page->Print("<center><table border=0 cellspacing=2 width=100%>");
	$Page->Print("<tr><td colspan=2>�e������͂���[�ݒ�]�{�^���������Ă��������B</td></tr>");
	$Page->Print("<tr><td colspan=2><hr></td></tr>");
	$Page->Print("<tr><td class=\"DetailTitle\" colspan=2>��{���</td></tr>");
	$Page->Print("<tr><td colspan=2><table cellspcing=2>");
	$Page->Print("<tr><td class=\"DetailTitle\">�O���[�v����</td><td>");
	$Page->Print("<input name=GROUPNAME type=text size=50 value=\"$name\"></td></tr>");
	$Page->Print("<tr><td class=\"DetailTitle\">����</td><td>");
	$Page->Print("<input name=GROUPSUBS type=text size=50 value=\"$expl\"></td></tr>");
	$Page->Print("</table><br></td></tr>\n");
	$Page->Print("<tr><td class=\"DetailTitle\" width=40%>�������</td>");
	$Page->Print("<td class=\"DetailTitle\">�������[�U</td></tr><tr><td valign=top>");

	# �����ꗗ�\��
	$Page->Print("<input type=checkbox name=A_USERGROUP $authNum[0] value=on>�Ǘ��O���[�v�ݒ�<br>");
	$Page->Print("<input type=checkbox name=A_CAPGROUP $authNum[1] value=on>�L���b�v�O���[�v�ݒ�<br>");
	$Page->Print("<input type=checkbox name=A_LOGVIEW $authNum[14] value=on>���O�̉{���E�폜<br>");
	$Page->Print("<hr>");
	$Page->Print("<input type=checkbox name=A_THREADSTOP $authNum[2] value=on>�X���b�h��~�E�ĊJ<br>");
	$Page->Print("<input type=checkbox name=A_THREADPOOL $authNum[3] value=on>�X���b�hdat�����E����<br>");
	$Page->Print("<input type=checkbox name=A_TREADDELETE $authNum[4] value=on>�X���b�h�폜<br>");
	$Page->Print("<input type=checkbox name=A_THREADINFO $authNum[5] value=on>�X���b�h���X�V<br>");
	$Page->Print("<input type=checkbox name=A_PASTCREATE $authNum[6] value=on>�ߋ����O����<br>");
	$Page->Print("<input type=checkbox name=A_PASTDELETE $authNum[7] value=on>�ߋ����O�폜<br>");
	$Page->Print("<input type=checkbox name=A_BBSSETTING $authNum[8] value=on>�f���ݒ�<br>");
	$Page->Print("<input type=checkbox name=A_BBSEDIT $authNum[13] value=on>�e��ҏW<br>");
	$Page->Print("<input type=checkbox name=A_NGWORDS $authNum[9] value=on>NG���[�h�ҏW<br>");
	$Page->Print("<input type=checkbox name=A_ACCESUSER $authNum[10] value=on>�A�N�Z�X�����ҏW<br>");
	$Page->Print("<hr>");
	$Page->Print("<input type=checkbox name=A_RESABONE $authNum[11] value=on>���X���ځ[��<br>");
	$Page->Print("<input type=checkbox name=A_RESEDIT $authNum[12] value=on>���X�ҏW<br>");
	$Page->Print("</td>\n<td valign=top>");

	# �������[�U�ꗗ�\��
	foreach $id (@userSet) {
		# �V�X�e���������[�U�A���̃O���[�v�ɏ������Ă��郆�[�U�͔�\��
		if (0 == $User->Get('SYSAD', $id) &&
			($Group->GetBelong($id) eq '' || $Group->GetBelong($id) eq $Form->Get('SELECT_GROUP'))) {
			my $userName = $User->Get('NAME', $id);
			my $fullName = $User->Get('FULL', $id);
			my $check = '';
			foreach (@user) {
				if ($_ eq $id) {
					$check = 'checked';
				}
			}
			$Page->Print("<input type=checkbox name=BELONGUSER value=$id $check>$userName($fullName)<br>");
		}
	}

	# submit�ݒ�
	$common = "'" . $Form->Get('MODE_SUB') . "'";
	$common = "onclick=\"DoSubmit('bbs.user','FUNC',$common)\"";

	$Page->HTMLInput('hidden', 'SELECT_GROUP', $Form->Get('SELECT_GROUP'));
	$Page->Print("</td></tr>");
	$Page->Print("<tr><td colspan=2><hr></td></tr>");
	$Page->Print("<tr><td colspan=2 align=left>");
	$Page->Print("<input type=submit value=\"�@�ݒ�@\" $common></td></tr>");
	$Page->Print("</table><br>");
}

#------------------------------------------------------------------------------------------------------------
#
#	�O���[�v�폜�m�F��ʂ̕\��
#	-------------------------------------------------------------------------------------
#	@param	$Page	�y�[�W�R���e�L�X�g
#	@param	$SYS	�V�X�e���ϐ�
#	@param	$Form	�t�H�[���ϐ�
#	@return	�Ȃ�
#
#------------------------------------------------------------------------------------------------------------
sub PrintGroupDelete
{
	my ($Page, $SYS, $Form) = @_;
	my ($Group, $BBS, @groupSet, $name, $expl, $rang, $id, $common);

	$SYS->Set('_TITLE', 'Group Delete Confirm');

	require './module/sys_security.pl';
	$Group = GILDOR->new;
	$Group->Load($SYS);

	# ���[�U�����擾
	@groupSet = $Form->GetAtArray('GROUPS');

	$Page->Print("<center><table border=0 cellspacing=2 width=100%>");
	$Page->Print("<tr><td colspan=2>�ȉ��̃O���[�v���폜���܂��B</td></tr>");
	$Page->Print("<tr><td colspan=2><hr></td></tr>");

	$Page->Print("<tr>");
	$Page->Print("<td class=\"DetailTitle\" style=\"width:150\">Group Name</td>");
	$Page->Print("<td class=\"DetailTitle\" style=\"width:200\">Subscription</td>");

	# ���[�U���X�g���o��
	foreach $id (@groupSet) {
		$name = $Group->Get('NAME', $id);
		$expl = $Group->Get('EXPL', $id);

		$Page->Print("<tr><td>$name</a></td>");
		$Page->Print("<td>$expl</td></tr>\n");
		$Page->HTMLInput('hidden', 'GROUPS', $id);
	}

	$Page->Print("<tr><td colspan=2><hr></td></tr>");
	$Page->Print("<tr><td bgcolor=yellow colspan=3><b><font color=red>");
	$Page->Print("�����F�폜�����O���[�v�����ɖ߂����Ƃ͂ł��܂���B</b><br>");
	$Page->Print("�����F�������������Ă���O���[�v�͍폜�ł��܂���B<br>");
	$Page->Print("�����F�폜����O���[�v�ɏ������Ă��郆�[�U�͂��ׂĖ�������ԂɂȂ�܂��B</td></tr>");
	$Page->Print("<tr><td colspan=2><hr></td></tr>");
	$Page->Print("<tr><td colspan=2 align=right><input type=button value=\"�@�폜�@\" ");
	$Page->Print("onclick=\"DoSubmit('bbs.user','FUNC','DELETE')\" class=\"delete\"></td></tr>");
	$Page->Print("</table>");
}

#------------------------------------------------------------------------------------------------------------
#
#	�C���|�[�g��ʂ̕\��
#	-------------------------------------------------------------------------------------
#	@param	$Page	�y�[�W�R���e�L�X�g
#	@param	$SYS	�V�X�e���ϐ�
#	@param	$Form	�t�H�[���ϐ�
#	@param	$BBS	BBS���
#	@return	�Ȃ�
#
#------------------------------------------------------------------------------------------------------------
sub PrintGroupImport
{
	my ($Page, $SYS, $Form, $BBS) = @_;
	my (@bbsSet, $id, $name);

	$SYS->Set('_TITLE', 'Group Import');

	# ����BBS���擾
	$SYS->Get('ADMIN')->{'SECINFO'}->GetBelongBBSList($SYS->Get('ADMIN')->{'USER'}, $BBS, \@bbsSet);

	$Page->Print("<center><table cellspcing=2 width=100%>");
	$Page->Print("<tr><td colspan=2><hr></td></tr>");
	$Page->Print("<tr><td class=\"DetailTitle\">����BBS����C���|�[�g</td>");
	$Page->Print("<td><select name=IMPORT_BBS><option value=\"\">--�f����I��--</option>");

	# �f���ꗗ�̏o��
	foreach $id (@bbsSet) {
		$name	= $BBS->Get('NAME', $id);
		$Page->Print("<option value=$id>$name</option>\n");
	}

	$Page->Print("</select></td></tr>");
	$Page->Print("<tr><td colspan=2><hr></td></tr>");
	$Page->Print("<tr><td colspan=2 align=left><input type=button value=\"�C���|�[�g\"");
	$Page->Print("onclick=\"DoSubmit('bbs.user','FUNC','IMPORT');\"></td></tr></table>");
}

#------------------------------------------------------------------------------------------------------------
#
#	�O���[�v�쐬/�ҏW
#	-------------------------------------------------------------------------------------
#	@param	$Sys	�V�X�e���ϐ�
#	@param	$Form	�t�H�[���ϐ�
#	@param	$mode	�ҏW:1, �쐬:0
#	@param	$pLog	���O�p
#	@return	�G���[�R�[�h
#
#------------------------------------------------------------------------------------------------------------
sub FunctionGroupSetting
{
	my ($Sys, $Form, $mode, $pLog) = @_;
	my ($Group, $User, @userSet, @authNum, @belongUser);
	my ($name, $expl, $auth, $user, $i);

	# �����`�F�b�N
	{
		my $SEC = $Sys->Get('ADMIN')->{'SECINFO'};
		my $chkID = $Sys->Get('ADMIN')->{'USER'};

		if (($SEC->IsAuthority($chkID, $ZP::AUTH_USERGROUP, $Sys->Get('BBS'))) == 0) {
			return 1000;
		}
	}
	# ���̓`�F�b�N
	{
		my @inList = ('GROUPNAME');
		if (! $Form->IsInput(\@inList)) {
			return 1001;
		}
	}
	require './module/sys_security.pl';
	$User = SYS_SECURITY->new;
	$Group = GILDOR->new;

	# ���[�U���̓ǂݍ���
	$User->Load($Sys);
	$Group->Load($Sys);

	# ��{���̐ݒ�
	$name = $Form->Get('GROUPNAME');
	$expl = $Form->Get('GROUPSUBS');

	# �������̐���
	my %field2auth = (
		'A_USERGROUP'	=> $ZP::AUTH_USERGROUP,
		'A_CAPGROUP'	=> $ZP::AUTH_CAPGROUP,
		'A_THREADSTOP'	=> $ZP::AUTH_THREADSTOP,
		'A_THREADPOOL'	=> $ZP::AUTH_THREADPOOL,
		'A_TREADDELETE'	=> $ZP::AUTH_TREADDELETE,
		'A_THREADINFO'	=> $ZP::AUTH_THREADINFO,
		'A_PASTCREATE'	=> $ZP::AUTH_KAKOCREATE,
		'A_PASTDELETE'	=> $ZP::AUTH_KAKODELETE,
		'A_BBSSETTING'	=> $ZP::AUTH_BBSSETTING,
		'A_NGWORDS'		=> $ZP::AUTH_NGWORDS,
		'A_ACCESUSER'	=> $ZP::AUTH_ACCESUSER,
		'A_RESABONE'	=> $ZP::AUTH_RESDELETE,
		'A_RESEDIT'		=> $ZP::AUTH_RESEDIT,
		'A_BBSEDIT'		=> $ZP::AUTH_BBSEDIT,
		'A_LOGVIEW'		=> $ZP::AUTH_LOGVIEW,
	);
	my @auths = ();
	foreach (keys %field2auth) {
		if ($Form->Equal($_, 'on')) {
			push @auths, $field2auth{$_};
		}
	}
	$auth = join(',', @auths);

	# �������[�U���̐���
	@belongUser = $Form->GetAtArray('BELONGUSER');
	$user = join(',', @belongUser);

	# �ݒ���̓o�^
	if ($mode) {
		my $groupID = $Form->Get('SELECT_GROUP');
		$Group->Set($groupID, 'NAME', $name);
		$Group->Set($groupID, 'EXPL', $expl);
		$Group->Set($groupID, 'AUTH', $auth);
		$Group->Set($groupID, 'USERS', $user);
	}
	else {
		$Group->Add($name, $expl, $auth, $user);
	}

	# �ݒ��ۑ�
	$Group->Save($Sys);

	# �������O
	{
		my $id;
		push @$pLog, '���ȉ��̃O���[�v��o�^���܂����B';
		push @$pLog, "�O���[�v���́F$name";
		push @$pLog, "�����F$expl";
		push @$pLog, "�����F$auth";
		push @$pLog, '�������[�U�F';
		foreach $id (@belongUser) {
			push @$pLog,"�@�@> " . $User->Get('NAME', $id);
		}
	}

	return 0;
}

#------------------------------------------------------------------------------------------------------------
#
#	�O���[�v�폜
#	-------------------------------------------------------------------------------------
#	@param	$Sys	�V�X�e���ϐ�
#	@param	$Form	�t�H�[���ϐ�
#	@param	$pLog	���O�p
#	@return	�G���[�R�[�h
#
#------------------------------------------------------------------------------------------------------------
sub FunctionGroupDelete
{
	my ($Sys, $Form, $pLog) = @_;
	my ($Group, @groupSet, $id);

	# �����`�F�b�N
	{
		my $SEC	= $Sys->Get('ADMIN')->{'SECINFO'};
		my $chkID = $Sys->Get('ADMIN')->{'USER'};

		if (($SEC->IsAuthority($chkID, $ZP::AUTH_USERGROUP, $Sys->Get('BBS'))) == 0) {
			return 1000;
		}
	}
	require './module/sys_security.pl';
	$Group = GILDOR->new;

	# ���[�U���̓ǂݍ���
	$Group->Load($Sys);

	push @$pLog, '���ȉ��̃O���[�v���폜���܂����B';
	@groupSet = $Form->GetAtArray('GROUPS');

	foreach $id (@groupSet) {
		next if (! defined $Group->Get('NAME', $id));
		if ($Group->GetBelong($Sys->Get('ADMIN')->{'USER'}) eq $id) {
			push(@$pLog,
				'�������̏����O���[�v�̂��߁u' . $Group->Get('NAME', $id) . '�v���폜�ł��܂���ł����B');
		}
		else {
			push @$pLog, $Group->Get('NAME', $id) . '(' . $Group->Get('EXPL', $id) . ')';
			$Group->Delete($id);
		}
	}

	# �ݒ�̕ۑ�
	$Group->Save($Sys);

	return 0;
}

#------------------------------------------------------------------------------------------------------------
#
#	�O���[�v�C���|�[�g
#	-------------------------------------------------------------------------------------
#	@param	$Sys	�V�X�e���ϐ�
#	@param	$Form	�t�H�[���ϐ�
#	@param	$pLog	���O�p
#	@return	�G���[�R�[�h
#
#------------------------------------------------------------------------------------------------------------
sub FunctionGroupImport
{
	my ($Sys, $Form, $pLog, $BBS) = @_;
	my ($src, $dst);

	# �����`�F�b�N
	{
		my $SEC = $Sys->Get('ADMIN')->{'SECINFO'};
		my $chkID = $Sys->Get('ADMIN')->{'USER'};

		if (($SEC->IsAuthority($chkID, $ZP::AUTH_USERGROUP, $Sys->Get('BBS'))) == 0) {
			return 1000;
		}
	}
	require './module/file_utils.pl';

	$src = $Sys->Get('BBSPATH') . '/' . $BBS->Get('DIR', $Form->Get('IMPORT_BBS', ''), '') . '/info/groups.cgi';
	$dst = $Sys->Get('BBSPATH') . '/' . $Sys->Get('BBS') . '/info/groups.cgi';

	return 0 if ($src eq $dst);

	# �O���[�v�ݒ���R�s�[
	FILE_UTILS::Copy($src, $dst);

	# ���O�̏o��
	my $name = $BBS->Get('NAME', $Form->Get('IMPORT_BBS'));
	push @$pLog, "�u$name�v�̃O���[�v�ݒ���C���|�[�g���܂����B";

	return 0;
}

#============================================================================================================
#	Module END
#============================================================================================================
1;