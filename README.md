# OpenVPN Server Docker image
Docker image for [OpenVPN](https://openvpn.net/) server with possibility to access to server network from vpn. This image is based on [Alpine Linux](https://hub.docker.com/_/alpine/) Docker image.

## Supported tags and respective `Dockerfile` links

* [`latest`](https://github.com/VGoshev/openvpn-docker/blob/master/docker/Dockerfile) - Latest available version.

## Quickstart

To run container you can use following command:
```bash
docker run \  
  -v /home/docker/openvpn:/etc/openvpn \  
  -p 1194:1194 \
  --cap-add=NET_ADMIN \
  -d sunx/openvpn
```

After first run container will create default configuration files for OpenVPN, which you should edit manually. Also you will need to add OpenVPN keys. For more info about configuring OpenVPN you could read [OpenVPN documentation](https://openvpn.net/index.php/open-source/documentation.html).

## Detailed description of image and containers

### NET_ADMIN capability

OpenVPN creates `tun` or `tap` device to its work, so you have to add NET_AMIN capability to container on run. Do do so you can add `--cap-add=NET_ADMIN` option to your `docker run` command.

### Used ports

By default OpenVPN uses port 1194. But you're free to choose any port you like.

### Volume
This image uses one volume with internal path `/etc/openvpn`, it will store configuration files and OpenVPN keys.

I would recommend you use host directory mapping of named volume to run containers, so you will not lose your valuable data after image update and starting new container.

### Configuration

Container based on this image will automatically set up iptables to add access from VPN to internet and vise versa. you can configure, which vpn subnet will be affected by its rules by passing `VPN_SUBNET` enviroment variable to container. Devault value of `VPN_SUBNET` is "10.0.0.0/16".

Container will add following iptables rules:
```bash
IPT="/sbin/iptables"
$IPT -t nat -A POSTROUTING -s $VPN_SUBNET -o eth0 -j MASQUERADE
$IPT -t nat -N ToVPN
$IPT -t nat -A POSTROUTING -d $VPN_SUBNET -o tun0 -j ToVPN
$IPT -t nat -A ToVPN -s $VPN_SUBNET -j RETURN
$IPT -t nat -A ToVPN -j MASQUERADE

$IPT -A INPUT -s $VPN_SUBNET -i !tun0 -j DROP
$IPT -A FORWARD -s $VPN_SUBNET -i tun0 -j ACCEPT
$IPT -A FORWARD -d $VPN_SUBNET -o tun0 -j ACCEPT
$IPT -A FORWARD -i eth0 -o eth0 -j DROP
$IPT -A OUTPUT -d $VPN_SUBNET -o !tun0 -j DROP
```

## License

This Dockerfile and scripts are released under [MIT License](https://github.com/VGoshev/openvpn-docker/blob/master/LICENSE).
