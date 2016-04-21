#!/bin/bash
#
# NixStats Installer
#
# @version		1.0.1
# @date			2016-03-03
# @copyright	(c) 2014 http://www.nixstats.com
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# Set environment
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
sysstat_version="sysstat-11.3.3"

if [ -n "$(command -v apt-get)" ]
then
    apt-get -q -y --force-yes update >/dev/null 2>&1
    apt-get -q -y --force-yes install apt-utils gzip curl make gcc xz-utils build-essential >/dev/null 2>&1
    service cron start >/dev/null 2>&1
    if [ ! -d /opt ]
    then
        mkdir /opt
    fi
    cd /opt
    wget http://pagesperso-orange.fr/sebastien.godard/$sysstat_version.tar.xz >/dev/null 2>&1
    unxz $sysstat_version.tar.xz >/dev/null 2>&1
    tar -xvf $sysstat_version.tar >/dev/null 2>&1
    cd $sysstat_version >/dev/null 2>&1
    echo "Configuring sysstat..."
    if [ -f /.dockerinit ]; then
        echo "I'm inside matrix ;(";
        oldstring=/proc
        newstring=/host/proc
        grep -rl $oldstring ./ | xargs sed -i s@$oldstring@$newstring@g
    else
        echo "I'm living in real world!";
    fi
    ./configure --prefix=/opt/sysstat --disable-file-attr --disable-nls >/dev/null 2>&1
    echo "Making sysstat..."
    make >/dev/null 2>&1
    echo "Installing sysstat..."
    make install >/dev/null 2>&1
    cd ../
    rm -rf sysstat*
fi

if [ -n "$(command -v yum)" ]
then
    yum -d0 -e0 -y install cronie gzip curl gcc make xz >/dev/null 2>&1
    service crond start >/dev/null 2>&1
    if [ ! -d /opt ]
    then
        mkdir /opt
    fi
    cd /opt
    wget http://pagesperso-orange.fr/sebastien.godard/$sysstat_version.tar.xz >/dev/null 2>&1
    unxz $sysstat_version.tar.xz >/dev/null 2>&1
    tar -xvf $sysstat_version.tar >/dev/null 2>&1
    cd $sysstat_version >/dev/null 2>&1
    echo "Configuring sysstat..."
    if [ -f /.dockerinit ]; then
        echo "I'm inside matrix ;(";
        oldstring=/proc
        newstring=/host/proc
        grep -rl $oldstring ./ | xargs sed -i s@$oldstring@$newstring@g
    else
        echo "I'm living in real world!";
    fi
    ./configure --prefix=/opt/sysstat --disable-file-attr --disable-nls >/dev/null 2>&1
    echo "Making sysstat..."
    make >/dev/null 2>&1
    echo "Installing sysstat..."
    make install >/dev/null 2>&1
    cd ../
    rm -rf sysstat*
fi

command -v crontab >/dev/null 2>&1 || { echo "cron is required but it's not installed.  Aborting." >&2; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "curl is required but it's not installed.  Aborting." >&2; exit 1; }

if [ ! -d /etc/nixstats ]
then
mkdir -p /etc/nixstats
fi

if [ ! -d /opt/nixstats ]
then
mkdir -p /opt/nixstats
fi

if [ ! -d /tmp/nixstats/retry ]
then
mkdir -p /tmp/nixstats/retry
fi

#remove old agent and download a new one
if [ -f /etc/nixstats/nixstats.sh ]
then
    rm -f /etc/nixstats/nixstats.sh
fi

curl -k -o /opt/nixstats/nixstats.sh http://www.nixstats.com/nixstats2.sh >/dev/null 2>&1

if [ -f /.dockerinit ]; then
    echo "I'm inside matrix ;(";
    oldstring=/proc
    newstring=/host/proc
    sed -i s@$oldstring@$newstring@g /opt/nixstats/nixstats.sh
else
    echo "I'm living in real world!";
    if [ ! -f /etc/nixstats/user ]
    then
        echo "$1" > /etc/nixstats/user
    fi
    
    if [ ! -f /etc/nixstats/serverid ]
    then
        echo "$(ip addr | grep inet) $(hostname)"  | sha256sum | awk '{print $1}' > /etc/nixstats/serverid
    fi
fi

if [ ! -f /etc/nixstats/token ]
then
touch /etc/nixstats/token
fi

if id -u nixstats >/dev/null 2>&1; then
        echo "User nixstats found."
        userdel nixstats
        useradd nixstats -r -d /opt/nixstats -s /bin/false
        chown -R nixstats:nixstats /opt/nixstats
        chown -R nixstats:nixstats /tmp/nixstats
        chown -R nixstats:nixstats /etc/nixstats
        chmod -R 700 /opt/nixstats
else
        echo "Adding user nixstats."
        useradd nixstats -r -d /opt/nixstats -s /bin/false
        chown -R nixstats:nixstats /opt/nixstats
        chown -R nixstats:nixstats /tmp/nixstats
        chown -R nixstats:nixstats /etc/nixstats
        chmod -R 700 /opt/nixstats
fi

#remove old cronjobs and add new ones
crontab -u nixstats -l | grep -v 'nixstats'  | crontab -u nixstats - >/dev/null 2>&1
crontab -u nixstats -l 2>/dev/null | { cat; echo "* * * * * bash /opt/nixstats/nixstats.sh > /dev/null 2>&1"; } | crontab -u nixstats - >/dev/null 2>&1

#remove the root cronjob
crontab -u root -l | grep -v 'nixstats'  | crontab -u root - >/dev/null 2>&1

echo "Installation complete!"

if [ -f $0 ]
then
    rm -f $0
fi
