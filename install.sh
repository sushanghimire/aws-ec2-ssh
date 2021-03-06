#!/bin/bash -x

# sample run command
# sh install.sh "ec2-admin,ec2-testers,ec2-readonly" "ec2-admin" "" "iam-synced-users"

IAM_AUTHORIZED_GROUPS="$1"
SUDOERSGROUP="$2"
LOCAL_GROUPS="$3"
LOCAL_MARKER_GROUP="iam-synced-users"
ASSUMEROLE=""

echo "IAM_AUTHORIZED_GROUPS: $IAM_AUTHORIZED_GROUPS"
echo "SUDOERSGROUP: $SUDOERSGROUP"
echo "LOCAL_GROUPS: $LOCAL_GROUPS"
echo "LOCAL_MARKER_GROUP: $LOCAL_MARKER_GROUP"
echo "ASSUMEROLE: $ASSUMEROLE"



# To control which users are imported/synced, uncomment the line below
# changing GROUPNAMES to a comma seperated list of IAM groups you want to sync.
# You can specify 1 or more groups, comma seperated, without spaces.
# If you leave it blank, all IAM users will be synced.
sed -i "s/IAM_AUTHORIZED_GROUPS=\"\"/IAM_AUTHORIZED_GROUPS=\"$IAM_AUTHORIZED_GROUPS\"/" import_users.sh

# To control which users are given sudo privileges, uncomment the line below
# changing GROUPNAME to either the name of the IAM group for sudo users, or
# to ##ALL## to give all users sudo access. If you leave it blank, no users will
# be given sudo access.
sed -i "s/SUDOERSGROUP=\"\"/SUDOERSGROUP=\"$SUDOERSGROUP\"/" import_users.sh

# To control which local groups a user will get, uncomment the line belong
# changing GROUPNAMES to a comma seperated list of local UNIX groups.
# If you live it blank, this setting will be ignored
#sed -i 's/LOCAL_GROUPS=""/LOCAL_GROUPS="GROUPNAMES"/' /opt/import_users.sh

# If your IAM users are in another AWS account, put the AssumeRole ARN here.
# replace the word ASSUMEROLEARN with the full arn. eg 'arn:aws:iam::$accountid:role/$role'
# See docs/multiawsaccount.md on how to make this work
#sed -i 's/ASSUMEROLE=""/ASSUMEROLE="ASSUMEROLEARN"/' /opt/import_users.sh
#sed -i 's/ASSUMEROLE=""/ASSUMEROLE="ASSUMEROLEARN"/' /opt/authorized_keys_command.sh

sed -i "s/LOCAL_GROUPS=\"\"/LOCAL_GROUPS=\"$LOCAL_GROUPS\"/" import_users.sh
sed -i "s/LOCAL_MARKER_GROUP=\"\"/LOCAL_MARKER_GROUP=\"$LOCAL_MARKER_GROUP\"/" import_users.sh



sed -i 's:#AuthorizedKeysCommand none:AuthorizedKeysCommand /opt/authorized_keys_command.sh:g' /etc/ssh/sshd_config
sed -i 's:#AuthorizedKeysCommandUser nobody:AuthorizedKeysCommandUser nobody:g' /etc/ssh/sshd_config


cp authorized_keys_command.sh /opt/authorized_keys_command.sh
cp import_users.sh /opt/import_users.sh


# echo "*/10 * * * * root /opt/import_users.sh" > /etc/cron.d/import_users
# chmod 0644 /etc/cron.d/import_users

/opt/import_users.sh
service sshd restart
