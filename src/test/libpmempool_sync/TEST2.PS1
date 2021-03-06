#
# Copyright 2016, Intel Corporation
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in
#       the documentation and/or other materials provided with the
#       distribution.
#
#     * Neither the name of the copyright holder nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#
# libpmempool_sync/TEST2.PS1 -- test for checking replica sync
#                               check if flags are supported
#                               pmem/issues#367
#
[CmdletBinding(PositionalBinding=$false)]
Param(
    [alias("d")]
    $DIR = ""
    )
$Env:UNITTEST_NAME = "libpmempool_sync\TEST2"
$Env:UNITTEST_NUM = "2"

# standard unit test setup
. ..\unittest\unittest.ps1

require_test_type medium
require_fs_type any

setup

$LOG = "out${Env:UNITTEST_NUM}.log"
$LOG_TEMP = "out${Env:UNITTEST_NUM}_part.log"
rm $LOG -Force -ea si
touch $LOG
rm $LOG_TEMP -Force -ea si
touch $LOG_TEMP

$LAYOUT = "OBJ_LAYOUT"
$POOLSET = "$DIR\poolset"

# Create poolset file
create_poolset $POOLSET `
	10M:$DIR\part00:x `
	r `
	10M:$DIR\part10:x

# Create a pool
expect_normal_exit $PMEMPOOL create --layout=$LAYOUT obj $POOLSET
cat $LOG >> $LOG_TEMP

# Delete a part from the second replica
rm $DIR\part10 -Force -ea si

# Try to synchronize replicas
$FLAGS = "2"
expect_abnormal_exit $Env:EXE_DIR\libpmempool_sync$Env:EXESUFFIX `
	$POOLSET $FLAGS
cat $LOG >> $LOG_TEMP

$FLAGS = "1024"
expect_abnormal_exit $Env:EXE_DIR\libpmempool_sync$Env:EXESUFFIX `
	$POOLSET $FLAGS
cat $LOG >> $LOG_TEMP

mv -Force $LOG_TEMP $LOG
check
pass
