#!/bin/sh

#
# Step 1: Detect the operating system
#
MAC="Mac OS X"
WIN="Windows"
LIN="Linux"

if [ -f /System/Library/Frameworks/Cocoa.framework/Cocoa ]; then
    OS=$MAC
elif [ -d /c/Windows ]; then
    OS=$WIN
else
    OS=$LIN
fi

# Move to src dir
APP_PATH=`echo $0 | awk '{split($0,patharr,"/"); idx=1; while(patharr[idx+1] != "") { if (patharr[idx] != "/") {printf("%s/", patharr[idx]); idx++ }} }'`
APP_PATH=`cd "$APP_PATH"; pwd`
cd "$APP_PATH"

#Set the basic paths
OUT_DIR="${APP_PATH}/../asteroids.out/master"
TMP_DIR="${APP_PATH}/tmp"
SRC_DIR="${APP_PATH}/src"
LIB_DIR="${APP_PATH}/lib"
LOG_FILE="${APP_PATH}/out.log"

PAS_FLAGS="-O3 -vw"
SG_INC="-Fu${APP_PATH}/lib/"

FPC_BIN=`which fpc`

GAME_NAME=${APP_PATH##*/}
ICON=SwinGame

CLEAN="N"

Usage()
{
    echo "Usage: [-c] [-h] [name]"
    echo
    echo "Compiles your game into an executable application."
    echo "Output is located in $OUT_DIR."
    echo
    echo "Options:"
    echo " -c   Perform a clean rather than a build"
    echo " -h   Show this help message "
    echo " -i [icon] Change the icon file"
    exit 0
}

while getopts chdi: o
do
    case "$o" in
    c)  CLEAN="Y" ;;
    h)  Usage ;;
    d)  DEBUG="Y" ;;
    i)  ICON="$OPTARG";;
    esac
done

shift $((${OPTIND}-1))

#
# Change directories based on release or debug builds
#
if [ "a${DEBUG}a" != "aa" ]; then
    if [ "$OS" = "$MAC" ]; then
        PAS_FLAGS="-gw -vw"
    else
        PAS_FLAGS="-g -vw"
    fi
    OUT_DIR="${OUT_DIR}.debug"
fi

if [ ! -d ${TMP_DIR} ]; then
    mkdir -p ${TMP_DIR}
fi

if [ -f "${LOG_FILE}" ]; then
    rm -f "${LOG_FILE}"
fi


DoExitCompile ()
{
    echo "An error occurred while compiling";
    cat out.log
    exit 1;
}

CleanTmp()
{
    if [ -d "${TMP_DIR}" ]
    then
        rm -rf "${TMP_DIR}"
    fi
    mkdir "${TMP_DIR}"
}

#
# Compile for Mac - manually assembles and links files
# argument 1 is arch
#
doMacCompile()
{
    mkdir -p ${TMP_DIR}/${1}
    echo "  ... Compiling $GAME_NAME - $1"

    ${FPC_BIN}  $PAS_FLAGS ${SG_INC} -Mobjfpc -Sh -FE${TMP_DIR}/${1} -FU${TMP_DIR}/${1} -Fu${LIB_DIR} -Fi${SRC_DIR} -s ${SRC_DIR}/GameMain.pas > ${LOG_FILE}
    if [ $? != 0 ]; then DoExitCompile; fi
    rm -f ${LOG_FILE}

    #Remove the pascal assembler script
    rm ${TMP_DIR}/${1}/ppas.sh

    echo "  ... Assembling for $1"

    #Assemble all of the .s files
    for file in `find ${TMP_DIR}/${1} | grep [.]s$`
    do
        /usr/bin/as -o ${file%.s}.o $file -arch $1
        if [ $? != 0 ]; then DoExitAsm $file; fi
        rm $file
    done

    echo "  ... Linking ${GAME_NAME}"

    FRAMEWORKS=`ls -d ${LIB_DIR}/*.framework | awk -F . '{split($1,patharr,"/"); idx=1; while(patharr[idx+1] != "") { idx++ } printf("-framework %s ", patharr[idx]) }'`

    /usr/bin/ld /usr/lib/crt1.o -F${LIB_DIR} -L/usr/X11R6/lib -L/usr/lib -search_paths_first -multiply_defined suppress -o "${TMP_DIR}/${1}/${GAME_NAME}" `cat ${TMP_DIR}/${1}/link.res` -framework Cocoa ${FRAMEWORKS}
    if [ $? != 0 ]; then DoExitLink ${GAME_NAME}; fi
}

#
# Create fat executable (i386 + ppc)
#
doLipo()
{
    echo "  ... Creating Universal Binary"
    lipo -arch ${1} "${TMP_DIR}/${1}/${GAME_NAME}" -arch ${2} "${TMP_DIR}/${2}/${GAME_NAME}" -output "${OUT_DIR}/${GAME_NAME}" -create
}

doMacPackage()
{
    GAMEAPP_PATH="${OUT_DIR}/${GAME_NAME}.app"
    if [ -d "${GAMEAPP_PATH}" ]
    then
    	echo "  ... Removing old application"
    	rm -rf "${GAMEAPP_PATH}"
    fi

    echo "  ... Creating Application Bundle"

    mkdir "${GAMEAPP_PATH}"
    mkdir "${GAMEAPP_PATH}/Contents"
    mkdir "${GAMEAPP_PATH}/Contents/MacOS"
    mkdir "${GAMEAPP_PATH}/Contents/Resources"
    mkdir "${GAMEAPP_PATH}/Contents/Frameworks"

    echo "  ... Added Private Frameworks"
    cp -R -p "${LIB_DIR}/"*.framework "${GAMEAPP_PATH}/Contents/Frameworks/"

    mv "${OUT_DIR}/${GAME_NAME}" "${GAMEAPP_PATH}/Contents/MacOS/"

    echo "<?xml version='1.0' encoding='UTF-8'?>\
    <!DOCTYPE plist PUBLIC \"-//Apple Computer//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\
    <plist version=\"1.0\">\
    <dict>\
            <key>CFBundleDevelopmentRegion</key>\
            <string>English</string>\
            <key>CFBundleExecutable</key>\
            <string>${GAME_NAME}</string>\
            <key>CFBundleIconFile</key>\
            <string>${ICON}</string>\
            <key>CFBundleIdentifier</key>\
            <string>au.edu.swinburne.${GAME_NAME}</string>\
            <key>CFBundleInfoDictionaryVersion</key>\
            <string>6.0</string>\
            <key>CFBundleName</key>\
            <string>${GAME_NAME}</string>\
            <key>CFBundlePackageType</key>\
            <string>APPL</string>\
            <key>CFBundleSignature</key>\
            <string>SWIN</string>\
            <key>CFBundleVersion</key>\
            <string>1.0</string>\
            <key>CSResourcesFileMapped</key>\
            <true/>\
    </dict>\
    </plist>" >> "${GAMEAPP_PATH}/Contents/Info.plist"

    echo "APPLSWIN" >> "${GAMEAPP_PATH}/Contents/PkgInfo"

    RESOURCE_DIR="${GAMEAPP_PATH}/Contents/Resources"
}

doLinuxCompile()
{
    mkdir -p ${TMP_DIR}
    echo "  ... Compiling $GAME_NAME"

    ${FPC_BIN}  ${PAS_FLAGS} ${SG_INC} -Mobjfpc -Sh -FE${OUT_DIR} -FU${TMP_DIR} -Fu${LIB_DIR} -Fi${SRC_DIR} -o${GAME_NAME} ${SRC_DIR}/GameMain.pas > ${LOG_FILE}
    if [ $? != 0 ]; then DoExitCompile; fi
}

doLinuxPackage()
{
    RESOURCE_DIR="${OUT_DIR}/Resources"
}

doWindowsCompile()
{
    mkdir -p ${TMP_DIR}

    echo "  ... Compiling $GAME_NAME"

    LIB_DIR=`echo $LIB_DIR | sed 's/\/\(.\)\//\1:\//'`          #awk '{sub("/c/", "c:/"); print}'`
    TMP_DIR=`echo $TMP_DIR | sed 's/\/\(.\)\//\1:\//'`          #awk '{sub("/c/", "c:/"); print}'`
    SRC_DIR=`echo $SRC_DIR | sed 's/\/\(.\)\//\1:\//'`          #awk '{sub("/c/", "c:/"); print}'`
    OUT_DIR=`echo $OUT_DIR | sed 's/\/\(.\)\//\1:\//'`          #awk '{sub("/c/", "c:/"); print}'`
    SG_INC=`echo $SG_INC | sed 's/\/\(.\)\//\1:\//'`            #awk '{sub("/c/", "c:/"); print}'`
    SG_INC=`echo $SG_INC | sed 's/\/\(.\)\//\1:\//'`            #awk '{sub("/c/", "c:/"); print}'`
    SG_INC=`echo $SG_INC | sed 's/\/\(.\)\//\1:\//'`            #awk '{sub("/c/", "c:/"); print}'`

    echo "  ... Creating Resources"
    windres ${SRC_DIR}/SwinGame.rc ${SRC_DIR}/GameLauncher.res
    if [ $? != 0 ]; then DoExitCompile; fi

    ${FPC_BIN}  ${PAS_FLAGS} ${SG_INC} -Mobjfpc -Sh -FE${OUT_DIR} -FU${TMP_DIR} -Fu${LIB_DIR} -Fi${SRC_DIR} -o${GAME_NAME}.exe ${SRC_DIR}/GameMain.pas > ${LOG_FILE}
    if [ $? != 0 ]; then DoExitCompile; fi

}

doWindowsPackage()
{
    RESOURCE_DIR=${OUT_DIR}/Resources

    echo "  ... Copying libraries"
    cp -p -f "${LIB_DIR}"/*.dll "${OUT_DIR}"
}


copyWithoutSVN()
{
    FROM_DIR=$1
    TO_DIR=$2

    cd "${FROM_DIR}"

    # Create directory structure
    find . -mindepth 1 ! -path \*.svn\* ! -path \*/. -type d -exec mkdir -p "${TO_DIR}/{}" \;
    # Copy files and links
    find . ! -path \*.svn\* ! -name \*.DS_Store ! -type d -exec cp -R -p {} "${TO_DIR}/{}"  \;
}

#
# Copy Resources from standard location to $RESOURCE_DIR
#
doCopyResources()
{
    echo "  ... Copying Resources into $GAME_NAME"

    copyWithoutSVN "${APP_PATH}/Resources" "${RESOURCE_DIR}"
}


if [ $CLEAN = "N" ]
then
    if [ ! -d "${OUT_DIR}" ]
    then
        mkdir -p "${OUT_DIR}"
    fi

    echo "--------------------------------------------------"
    echo "          Creating $GAME_NAME"
    echo "          for $OS"
    echo "--------------------------------------------------"
    echo "  Running script from $APP_PATH"
    echo "  Saving output to $OUT_DIR"
    echo "  Compiler flags ${SG_INC} ${C_FLAGS}"
    echo "--------------------------------------------------"
    echo "  ... Creating ${GAME_NAME}"

    if [ "$OS" = "$MAC" ]; then
        FPC_BIN="/usr/local/bin/ppc386" #old: `which ppc386`
        doMacCompile "i386"
        #FPC_BIN="/usr/local/bin/ppcppc"
        #doMacCompile "ppc"

        #doLipo "i386" "ppc"
        doMacPackage
    elif [ "$OS" = "$LIN" ]; then
        doLinuxCompile
        doLinuxPackage
    else
        doWindowsCompile
        doWindowsPackage
    fi

    doCopyResources
else
    CleanTmp
    rm -rf "${OUT_DIR}"
    mkdir "${OUT_DIR}"
    echo    ... Cleaned
fi

#remove temp files on success
rm -f ${LOG_FILE} 2>> /dev/null

echo "  Finished"
echo "--------------------------------------------------"
