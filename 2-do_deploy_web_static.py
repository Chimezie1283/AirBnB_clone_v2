#!/usr/bin/python3
"""[Fabric script]
"""
from fabric.api import env
from fabric.api import put
from fabric.api import run
from fabric.api import local
from datetime import datetime
from os import path

env.hosts = ['34.75.254.10', '34.75.125.125']
env.user = "ubuntu"


def do_pack():
    """[generates a .tgz archive]
    """
    time_format = '%Y%m%d%H%M%S'
    time = datetime.utcnow().strftime(time_format)
    filepath = "versions/web_static_{}.tgz".format(time)
    local("mkdir -p versions")
    local("tar -cvzf {} web_static".format(filepath))
    if path.exists(filepath):
        return filepath
    else:
        return None


def do_deploy(archive_path):
    """[distributes an archive to your web servers]

    Args:
        archive_path ([path]): [path of the archive file]
    """
    if not path.exists(archive_path) and path.isfile(archive_path):
        return False
    filename = archive_path.split("/")[-1].split(".")[0]
    path1 = "/data/web_static/releases/{}/web_static/*".format(filename)
    try:
        put(archive_path, "/tmp/")
        run("sudo mkdir -p /data/web_static/releases/{}/".format(filename))
        run("sudo tar -xzf /tmp/{}.tgz -C /data/web_static/releases/{}/".
            format(filename, filename))
        run("sudo rm /tmp/{}.tgz".format(filename))
        run("sudo mv {} /data/web_static/releases/{}/".format(path1, filename))
        run("sudo rm -rf /data/web_static/releases/{}/web_static".
            format(filename))
        run("sudo rm -rf /data/web_static/current")
        run("sudo ln -s /data/web_static/releases/{}/ /data/web_static/current"
            .format(filename))
        return True
    except:
        return False
    return True
