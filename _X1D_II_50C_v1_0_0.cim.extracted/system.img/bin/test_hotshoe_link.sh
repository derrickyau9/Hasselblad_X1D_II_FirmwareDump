#########################################################################
# File Name: test_hotshoe_link.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Sat 26 May 2018 06:44:07 PM CST
#########################################################################
#!/bin/bash
hotshoe_test()
{
	odindb-send -s suc -m func_test E_FuncTestModule_HotShoe E_FuncTestAction_Start 0 0 0
	if [ $? != 0 ]; then
		echo "odindb-send failed!"
		return 1
	fi
	echo "hotshoe test pass!"
	return 0
}

hotshoe_test
exit $?
