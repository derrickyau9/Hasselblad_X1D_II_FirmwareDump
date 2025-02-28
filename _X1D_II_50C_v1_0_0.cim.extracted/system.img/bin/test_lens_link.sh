#########################################################################
# File Name: test_lens_link.sh
# version V1.0
# Author: holmes.xie
# mail: holmes.xie@dji.com
# Created Time: Sat 26 May 2018 08:40:57 PM CST
#########################################################################
#########################################################################
# File Name: test_lens_link.sh
# version V2.0
# Author: rose.cai
# mail: rose.cai@dji.com
# Created Time: Aug 15, 2018 8:37 PM
#########################################################################
#!/bin/bash
#have test SUC: 1.SCL_LENS; 2.SDA_LENS; 3.LENS_ULAN_LENS; 4.LENS_WUP_LENS; 5.LENS_5V_LENS; 6.VSYS_LENS
#have test FARM: 1.AF_LENS_IN 2.AF_LENS_OUT 3.FSYNC_LENS

lens_if_test()
{

	sleep 1
#HotPlug sequence test
	odindb-send -s suc -m func_test E_FuncTestModule_LensIf E_FuncTestAction_Start 0 0 0
	if [ $? != 0 ]; then
		echo "lens if test failed!"
		return 1
	fi
	sleep 1
#HotShoe connecter test
	odindb-send -s suc -m func_test E_FuncTestModule_HotShoe E_FuncTestAction_Start 0 0 0
	if [ $? != 0 ]; then
		echo "hotshoe test failed!"
		return 1
	fi
	sleep 1
#Lens Flash sync pin test
	odindb-send -s camera -m do_exposure false
	if [ $? != 0 ]; then
		echo "lens flash test failed!"
		return 1
	else
		echo "Please check NikonFlash!"
	fi
	sleep 1
#Lens Af fsync pin test
	odindb-send -s farmus -m func_test E_FuncTestModule_LensIf E_FuncTestAction_Stop 0 0 0
	odindb-send -s camera -m set_live_view_state 0
	sleep 1

	odindb-send -s farmus -m func_test E_FuncTestModule_LensIf E_FuncTestAction_Start 30 0 0

	# This starts a session and forces AF
	odindb-send -s camera -m start_session false true

	sleep 1
	odindb-send -s farmus -m func_test E_FuncTestModule_LensIf E_FuncTestAction_Check 1 0 0
	if [ $? != 0 ]; then
		echo "lens af test failed!"
		odindb-send -s farmus -m func_test E_FuncTestModule_LensIf E_FuncTestAction_Stop 0 0 0
		odindb-send -s camera -m stop_session
		odindb-send -s camera -m set_live_view_state 0
		return 1
	fi
	odindb-send -s farmus -m func_test E_FuncTestModule_LensIf E_FuncTestAction_Stop 0 0 0
	odindb-send -s camera -m stop_session
	odindb-send -s camera -m set_live_view_state 0

	echo "lens if test pass!"
	return 0
}

lens_if_test
exit $?
