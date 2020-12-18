# Adze
Cardano-node Management Cli for NixOS

### How to :

### Make the script executable: 
$ chmod +x adze.sh

### Than launch:	
$ ./adze.sh

### We suggest to choose options:

1. Install Default Command.

3. Install or Update TestNet.

7. Launch TESTnet Node.

### Cache Configuration

## As root use the content in nixos folder and create a file call iohk-binary-cache.nix 
- nano /etc/nixos/iohk-binary-cache.nix
- copy paste or clone nixos folder content
## Next
- nano /etc/nixos/configuration.nix
        ## Add the link to the file imports section should be similar to this :
          ##     imports =
          ##          [
          ##              ./hardware-configuration.nix
          ##              ./iohk-binary-cache.nix
          ##          ];
