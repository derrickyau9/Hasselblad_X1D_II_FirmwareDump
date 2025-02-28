#########################################################################
# File Name: test_lens_if_link.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Sat 26 May 2018 08:40:57 PM CST
#########################################################################
#!/bin/bash
#have test 2.SCL_LENS; 3.SDA_LENS;4.LENS_ULAN_LENS;5.LENS_WUP_LENS;6.LENS_5V_LENS;7.VSYS_LENS

lens_if_test()
{
	odindb-send -s suc -m func_test E_FuncTestModule_LensIf E_FuncTestAction_Start 0 0 0
	if [ $? != 0 ]; then
		echo "lens if test failed!"
		return 1
	fi

	echo "lens if test pass!"
	return 0
}

lens_if_test
exit $?
