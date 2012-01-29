#This script creates a fat-lib if you compiled this library for more than one architecture (e.g. for arm and i386)
#@author: René Meye

#The following configuration should be set in the XCode Build settings
#Debug Workaround: COMBINED_FOLDER_NAME="iOS_OSX_combined"
if [ -n ${COMBINED_FOLDER_NAME}]; then
    echo "You have to set a Build Setting for the name of your fat-lib folder (COMBINED_FOLDER_NAME). --> Exiting."
    exit 1
fi

#Get the produced file name
LIBRARY_NAME=${EXECUTABLE_PREFIX}${TARGET_NAME}${EXECUTABLE_SUFFIX}

#Exiting in Case of Build Fails
if [ ! -d $TARGET_BUILD_DIR ]; then
    echo "It seems the Target had not been built yet. --> Exiting."
    exit 0
fi

LIB_BASE_DIR=${TARGET_BUILD_DIR}"/../" 
FAT_LIB=$LIB_BASE_DIR/$COMBINED_FOLDER_NAME/${LIBRARY_NAME}

#The Base are all libraries with the same (LIBRARY_NAME) name within the first subdirectories
BASE_LIBS=$LIB_BASE_DIR/*/$LIBRARY_NAME
#*/ <-- only a workaround for the sh**t syntax highlighting in XCode 4.2.1 (which can't handle the star-slash combination in the last line)
                        
#Count all existing base libraries (minus the fat library)
LIB_COUNT=$(echo $BASE_LIBS | wc -w)
if [ -f $FAT_LIB ]; then
    LIB_COUNT=$(( $LIB_COUNT - 1 ))
fi

#Exit if there is only one library (then there should be nothing todo^^)
if [ "$LIB_COUNT" -lt "2" ]; then
    echo "There is only one or less Library --> nothing to combine. Exiting." 
    exit 0
fi

#Create the Target directory if it's not there yet
mkdir -p $LIB_BASE_DIR/$COMBINED_FOLDER_NAME

#Delete an existing fat-lib in order to be sure it wont be merged again.
rm -f $FAT_LIB

#Combine all libraries with the same name within the first subdirectories
lipo $BASE_LIBS -create -output $FAT_LIB                              

