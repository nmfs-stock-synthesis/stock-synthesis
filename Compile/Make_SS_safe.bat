REM compiling ss.exe (safe executable) with generic path
REM requires "Compile" directory in the same directory where
REM the .tpl files and this .bat file sit.
cd ..
REM deleted temporary file
del SS_functions.temp

REM create SS_functions.temp file combining various functions
copy/b SS_biofxn.tpl+SS_miscfxn.tpl+SS_selex.tpl+SS_popdyn.tpl+SS_recruit.tpl+SS_benchfore.tpl+SS_expval.tpl+SS_objfunc.tpl+SS_write.tpl+SS_write_ssnew.tpl+SS_write_report.tpl+SS_ALK.tpl+SS_timevaryparm.tpl+SS_tagrecap.tpl SS_functions.temp

REM combine remaining files to create ss.tpl
copy/b SS_versioninfo_330safe.tpl+SS_readstarter.tpl+SS_readdata_330.tpl+SS_readcontrol_330.tpl+SS_param.tpl+SS_prelim.tpl+SS_global.tpl+SS_proced.tpl+SS_functions.temp "Compile\ss.tpl"

cd "Compile"

REM set CXX=cl
set CXX=g++

admb ss

REM below is echo of the commands executed by "admb" above
REM tpl2cpp   ss
REM Compile: ss.cpp
REM g++ -c -std=c++14 -O3 -fpermissive -D_FILE_OFFSET_BITS=64 -DUSE_ADMB_CONTRIBS -D_USE_MATH_DEFINES -I. -I"C:\ADMB-12.2\include" -I"C:\ADMB-12.2\include\contrib" -o ss.obj ss.cpp
REM Linking: ss.obj
REM g++ -static -o ss.exe ss.obj "C:\ADMB-12.2\lib\libadmb-contrib-mingw64-g++8.a"

