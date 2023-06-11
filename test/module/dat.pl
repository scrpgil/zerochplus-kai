#============================================================================================================
#
#	datファイル管理モジュール
#
#============================================================================================================
package	DAT;

use strict;
#use warnings;

#------------------------------------------------------------------------------------------------------------
#
#	コンストラクタ
#	-------------------------------------------------------------------------------------
#	@param	なし
#	@return	モジュールオブジェクト
#
#------------------------------------------------------------------------------------------------------------
sub new
{
	my $class = shift;

	my $obj = {
		'LINE'		=> undef,
		'PATH'		=> undef,
		'RES'		=> undef,
		'HANDLE'	=> undef,
		'MAX'		=> undef,
		'STAT'		=> 0,
		'PERM'		=> undef,
		'MODE'		=> undef,
	};
	bless $obj, $class;

	return $obj;
}

#------------------------------------------------------------------------------------------------------------
#
#	デストラクタ
#	-------------------------------------------------------------------------------------
#	@param	なし
#	@return	なし
#
#------------------------------------------------------------------------------------------------------------
sub DESTROY
{
	my $this = shift;

	# ファイルオープン状態の場合はクローズする
	if ($this->{'STAT'}) {
		my $fh = $this->{'HANDLE'};
		if ($fh) {
			#truncate($fh, tell($fh));
			close($fh);
			chmod $this->{'PERM'}, $this->{'PATH'};
		}
	}
}

#------------------------------------------------------------------------------------------------------------
#
#	読み込み
#	-------------------------------------------------------------------------------------
#	@param	$Sys		SYS_DATA
#	@param	$szPath		読み込みパス
#	@param	$readOnly	モード
#	@return	成功したら読み込んだレス数
#
#------------------------------------------------------------------------------------------------------------
sub Load
{
	my $this = shift;
	my ($Sys, $szPath, $readOnly) = @_;

	# 状態が初期状態なら読み込み開始
	if ($this->{'STAT'} == 0) {
		$this->{'RES'} = 0;
		$this->{'LINE'} = [];
		$this->{'MAX'} = $Sys->Get('RESMAX');
		$this->{'PATH'} = $szPath;
		$this->{'PERM'} = GetPermission($szPath);
		$this->{'MODE'} = $readOnly;

		chmod($Sys->Get('PM-DAT'), $szPath);
		if (open(my $fh, ($readOnly ? '<' : '+<'), $szPath)) {
			flock($fh, 2);
			binmode($fh);
			my @lines = <$fh>;

			push @{$this->{'LINE'}}, @lines;

			# 書き込みモードの場合
			seek($fh, 0, 0) if (! $readOnly);

			# ハンドルを保存し状態を読み込み状態にする
			$this->{'HANDLE'} = $fh;
			$this->{'STAT'} = 1;
			$this->{'RES'} = scalar(@{$this->{'LINE'}});
		}

		return $this->{'RES'};
	}

	return 0;
}

#------------------------------------------------------------------------------------------------------------
#
#	再読み込み
#	-------------------------------------------------------------------------------------
#	@param	$Sys		SYS_DATA
#	@param	$readOnly	モード
#	@return	成功したら読み込んだレス数
#
#------------------------------------------------------------------------------------------------------------
sub ReLoad
{
	my $this = shift;
	my ($Sys, $readOnly) = @_;

	if ($this->{'STAT'}) {
		$this->Close();
		return $this->Load($Sys, $this->{'PATH'}, $readOnly);
	}
	return 0;
}

#------------------------------------------------------------------------------------------------------------
#
#	書き込み
#	-------------------------------------------------------------------------------------
#	@param	$Sys	SYS_DATA
#	@return	なし
#
#------------------------------------------------------------------------------------------------------------
sub Save
{
	my $this = shift;
	my ($Sys) = @_;

	# ファイルオープン状態なら書き込みを実行する
	my $fh = $this->{'HANDLE'};
	if ($this->{'STAT'} && $fh) {
		if (! $this->{'MODE'}) {
			seek($fh, 0, 0);
			print $fh @{$this->{'LINE'}};
			truncate($fh, tell($fh));
			close($fh);

			chmod($this->{'PERM'}, $this->{'PATH'});
			$this->{'STAT'} = 0;
			$this->{'HANDLE'} = undef;
		}
		else {
			$this->Close();
		}
	}
}

#------------------------------------------------------------------------------------------------------------
#
#	強制クローズ
#	-------------------------------------------------------------------------------------
#	@param	なし
#	@return	なし
#
#------------------------------------------------------------------------------------------------------------
sub Close
{
	my $this = shift;

	# ファイルオープン状態の場合はクローズする
	if ($this->{'STAT'}) {
		my $fh = $this->{'HANDLE'};
		#truncate($handle, tell($handle));
		close($fh);

		chmod($this->{'PERM'}, $this->{'PATH'});
		$this->{'STAT'} = 0;
		$this->{'HANDLE'} = undef;
	}
}

#------------------------------------------------------------------------------------------------------------
#
#	データ設定
#	-------------------------------------------------------------------------------------
#	@param	$line	設定行
#	@param	$data	設定データ
#	@return	なし
#
#------------------------------------------------------------------------------------------------------------
sub Set
{
	my $this = shift;
	my ($line, $data) = @_;

	$this->{'LINE'}->[$line] = $data;
}

#------------------------------------------------------------------------------------------------------------
#
#	データ取得
#	-------------------------------------------------------------------------------------
#	@param	$line	取得行
#	@return	行データの参照
#
#------------------------------------------------------------------------------------------------------------
sub Get
{
	my $this = shift;
	my ($line) = @_;

	if ($line >= 0 && $line < $this->{'RES'}) {
		return \($this->{'LINE'}->[$line]);
	}
	return undef;
}

#------------------------------------------------------------------------------------------------------------
#
#	データ追加
#	-------------------------------------------------------------------------------------
#	@param	$data	追加データ
#	@return	なし
#
#------------------------------------------------------------------------------------------------------------
sub Add
{
	my $this = shift;
	my ($data) = @_;

	# 最大データ数内なら追加する
	if ($this->{'MAX'} > $this->{'RES'}) {
		push @{$this->{'LINE'}}, $data;
		$this->{'RES'}++;
	}
}

#------------------------------------------------------------------------------------------------------------
#
#	データ削除
#	-------------------------------------------------------------------------------------
#	@param	$num	削除行
#	@return	なし
#
#------------------------------------------------------------------------------------------------------------
sub Delete
{
	my $this = shift;
	my ($num) = @_;

	splice @{$this->{'LINE'}}, $num, 1;
	$this->{'RES'}--;
}

#------------------------------------------------------------------------------------------------------------
#
#	レス数取得
#	-------------------------------------------------------------------------------------
#	@param	なし
#	@return	レス数
#
#------------------------------------------------------------------------------------------------------------
sub Size
{
	my $this = shift;

	return $this->{'RES'};
}

#------------------------------------------------------------------------------------------------------------
#
#	サブジェクト取得
#	-------------------------------------------------------------------------------------
#	@param	なし
#	@return	サブジェクト
#
#------------------------------------------------------------------------------------------------------------
sub GetSubject
{
	my $this = shift;

	my @elem = split(/<>/, $this->{'LINE'}->[0], -1);
	$elem[4] =~ s/[\r\n]+\z//;

	return $elem[4];
}

#------------------------------------------------------------------------------------------------------------
#
#	スレッド停止 * 0.8.xから非推奨
#	-------------------------------------------------------------------------------------
#	@param	$Sys	SYS_DATA
#	@return	成功:1 失敗:0
#
#------------------------------------------------------------------------------------------------------------
sub Stop
{
	my $this = shift;
	my ($Sys) = @_;

	# ↓スレスト文言
	my $stopData = "停止しました。。。<>停止<>停止<>真・スレッドストッパー。。。（￣ー￣）ﾆﾔﾘｯ<>停止したよ。\n";

	# レス最大数超えてる場合はスレスト不可
	if ($this->Size() <= $Sys->Get('RESMAX')) {
		# 停止状態じゃない場合のみ実行
		if (! $this->IsStopped($Sys)) {
			# 停止データを追加して強制的にセーブする
			$this->Add($stopData);
			$this->Save($Sys);

			# パーミッションを停止用に設定する
			chmod($Sys->Get('PM-STOP'), $this->{'PATH'});
			return 1;
		}
	}

	return 0;
}

#------------------------------------------------------------------------------------------------------------
#
#	スレッド開始 * 0.8.xから非推奨
#	-------------------------------------------------------------------------------------
#	@param	$Sys	SYS_DATA
#	@return	成功:1 失敗:0
#
#------------------------------------------------------------------------------------------------------------
sub Start
{
	my $this = shift;
	my ($Sys) = @_;

	# 停止状態の場合のみ実行
	if ($this->IsStopped($Sys)) {
		# 最終行を削除して保存
		my $line = $this->{'RES'} - 1;
		$this->Delete($line);
		$this->Save($Sys);

		# パーミッションを通常用に設定する
		chmod($Sys->Get('PM-DAT'), $this->{'PATH'});
		return 1;
	}

	return 0;
}

#------------------------------------------------------------------------------------------------------------
#
#	dat直接追記
#	-------------------------------------------------------------------------------------
#	@param	$Sys	SYS_DATA
#	@param	$path	追記ファイルパス
#	@param	$data	追記データ
#	@return	追記できたら0を返す
#
#------------------------------------------------------------------------------------------------------------
sub DirectAppend
{
	my ($Sys, $path, $data) = @_;

	if (GetPermission($path) != $Sys->Get('PM-STOP')) {
		if (open(my $fh, '>>', $path)) {
			flock($fh, 2);
			binmode($fh);
			print $fh "$data";
			close($fh);
			chmod($Sys->Get('PM-DAT'), $path);
			return 0;
		}
	}
	else {
		return 2;
	}

	return 1;
}

#------------------------------------------------------------------------------------------------------------
#
#	ファイル指定レス数取得
#	-------------------------------------------------------------------------------------
#	@param	$path	指定ファイルパス
#	@return	レス数
#
#------------------------------------------------------------------------------------------------------------
sub GetNumFromFile
{
	my ($path) = @_;

	my $cnt = 0;
	if (open(my $fh, '<', $path)) {
		flock($fh, 2);
		$cnt++ while (<$fh>);
		close($fh);
	}
	return $cnt;
}

#------------------------------------------------------------------------------------------------------------
#
#	パーミッション取得
#	-------------------------------------------------------------------------------------
#	@param	$path	指定ファイルパス
#	@return	パーミッション
#
#------------------------------------------------------------------------------------------------------------
sub GetPermission
{
	my ($path) = @_;

	return (-e $path ? (stat $path)[2] & 0777 : 0);
}

#------------------------------------------------------------------------------------------------------------
#
#	移転検査
#	-------------------------------------------------------------------------------------
#	@param	$path	指定ファイルパス
#	@return	パーミッション
#
#------------------------------------------------------------------------------------------------------------
sub IsMoved
{
	my ($path) = @_;

	if (open(my $fh, '<', $path)) {
		flock($fh, 2);
		my $line = <$fh>;
		close($fh);

		my @elem = split(/<>/, $line, -1);
		if ($elem[2] ne '移転') {
			return 0;
		}
	}

	return 1;
}

#------------------------------------------------------------------------------------------------------------
#
#	停止検査 * 0.8.xから非推奨
#	-------------------------------------------------------------------------------------
#	@param	$Sys	SYS_DATA
#	@return	boolean
#
#------------------------------------------------------------------------------------------------------------
sub IsStopped
{
	my $this = shift;
	my ($Sys) = @_;

	return $this->{'PERM'} == $Sys->Get('PM-STOP');
}

#============================================================================================================
#	Module END
#============================================================================================================
1;
