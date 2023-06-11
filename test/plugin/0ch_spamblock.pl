#============================================================================================================
#
#	拡張機能 - 出会いスパムキャンセラー！
#	0ch_spam_block.pl
#
#	by windyakin ◆windyaking
#
#	http://windyakin.net/
#
#	---------------------------------------------------------------------------
#
#	2010.06.17 start
#
#============================================================================================================
package ZPL_spamblock;

#------------------------------------------------------------------------------------------------------------
#
#	コンストラクタ
#	-------------------------------------------------------------------------------------
#	@param	なし
#	@return	オブジェクト
#
#------------------------------------------------------------------------------------------------------------
sub new
{
	my $this = shift;
	my $obj={};
	bless($obj,$this);
	return $obj;
}

#------------------------------------------------------------------------------------------------------------
#
#	拡張機能名称取得
#	-------------------------------------------------------------------------------------
#	@param	なし
#	@return	名称文字列
#
#------------------------------------------------------------------------------------------------------------
sub getName
{
	my	$this = shift;
	return '出会いスパムキャンセラー';
}

#------------------------------------------------------------------------------------------------------------
#
#	拡張機能説明取得
#	-------------------------------------------------------------------------------------
#	@param	なし
#	@return	説明文字列
#
#------------------------------------------------------------------------------------------------------------
sub getExplanation
{
	my	$this = shift;
	return 'URLを調べて解析します';
}

#------------------------------------------------------------------------------------------------------------
#
#	拡張機能タイプ取得
#	-------------------------------------------------------------------------------------
#	@param	なし
#	@return	拡張機能タイプ(スレ立て:1,レス:2,read:4,index:8)
#
#------------------------------------------------------------------------------------------------------------
sub getType
{
	my	$this = shift;
	return (1 | 2);
}

#------------------------------------------------------------------------------------------------------------
#
#	拡張機能実行インタフェイス
#	-------------------------------------------------------------------------------------
#	@param	$sys	SYS_DATA
#	@param	$form	SAMWISE
#	@return	正常終了の場合は0
#
#------------------------------------------------------------------------------------------------------------
sub execute
{
	my $this = shift;
	my ($sys, $form) = @_;
	my ( @ng_addr, $mes, $bin_addr, $result );

	# 禁止IPアドレス
	@ng_addr  = ( '66.71.248.210', '174.122.102.1', '74.207.244.52', '74.207.242.227' );

	# メッセージを取得
	$mes = $form->Get('MESSAGE');

	# Encode.pmの使い方わかんないんですぅ＞＜
	require Encode;
	Encode::from_to( $mes, "Shift_JIS", "UTF-8" );

	while ( $mes =~ /(h?ttp:\/\/)?([0-9a-zA-Z\.\-]+\.(?:com|net|info|me|mobi|cc|asia|org|biz|co|in|tv|ch|at|mn|la|vg|ms|gs|vc|bz|ws|be|so))/ig )
	{

		# ホストを調査
		$bin_addr = gethostbyname($2);
		$result = sprintf("%vd", $bin_addr);

		# エラーを返すよ
		foreach ( @ng_addr ) {
			if ( $_ eq $result ) {
				PrintBBSError( $sys, $form, 205 );
			}
		}

	}

	return 0;
}

#------------------------------------------------------------------------------------------------------------
#
#	なんちゃってbbs.cgiエラーページ表示
#	-------------------------------------------------------------------------------------
#	@param	$sys	SYS_DATA
#	@param	$form	SAMWISE
#	@param	$err	エラー番号
#	@return	なし
#	exit	エラー番号
#
#------------------------------------------------------------------------------------------------------------
sub PrintBBSError
{
	my ($sys,$form,$err) = @_;
	my $SYS;

	require('./module/radagast.pl');
	require('./module/settings.pl');
	require('./module/thorin.pl');

	$SYS->{'SYS'}		= $sys;
	$SYS->{'FORM'}		= $form;
	$SYS->{'COOKIE'}	= new RADAGAST;
	$SYS->{'COOKIE'}->Init();
	$SYS->{'SET'}		= new SETTINGS;
	$SYS->{'SET'}->Load($sys);
	my $Page = new THORIN;

	require('./module/error.pl');
	$ERROR = new ERROR;
	$ERROR->Load($sys);

	$ERROR->Print($SYS,$Page,$err,$sys->Get('AGENT'));

	$Page->Flush('',0,0);

	exit($err);
}

#============================================================================================================
#	Module END
#============================================================================================================
1;
__END__
