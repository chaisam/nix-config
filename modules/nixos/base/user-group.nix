{
  username,
  config,
  ...
}: {
  # Don't allow mutation of users outside the config.
  users.mutableUsers = false;

  users.groups = {
    "${username}" = {};
    docker = {};
    wireshark = {};
    # for android platform tools's udev rules
    adbusers = {};
    dialout = {};
    # for openocd (embedded system development)
    plugdev = {};
    # misc
    uinput = {};
  };

  users.users."${username}" = {
    # generated by `mkpasswd -m scrypt`
    # we have to use initialHashedPassword here when using tmpfs for /
    initialHashedPassword = "$7$CU..../....Sdl/JRH..9eIvZ6mE/52r.$xeR6lyvTcVVKt28Owcoc/vPOOECcYSiq1xjw/QCz2t0";
    home = "/home/${username}";
    isNormalUser = true;
    extraGroups = [
      username
      "users"
      "networkmanager"
      "wheel"
      "docker"
      "wireshark"
      "adbusers"
      "libvirtd"
    ];

  };
  users.users.root = {
    initialHashedPassword = "$7$CU..../....X6uvZYnFD.i1CqqFFNl4./$4vgqzIPyw5XBr0aCDFbY/UIRRJr7h5SMGoQ/ZvX3FP2";
    openssh.authorizedKeys.keys = config.users.users."${username}".openssh.authorizedKeys.keys;
  };

  # DO NOT promote the specified user to input password for `nix-store` and `nix-copy-closure`
  security.sudo.extraRules = [
    {
      users = [username];
      commands = [
        {
          command = "/run/current-system/sw/bin/nix-store";
          options = ["NOPASSWD"];
        }
        {
          command = "/run/current-system/sw/bin/nix-copy-closure";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];
}