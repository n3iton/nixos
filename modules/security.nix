{ ... }:
{
  security.polkit.enable = true;

  security.pam.services = {
    login.fprintAuth = true;
    sudo.fprintAuth = true;
    su.fprintAuth = true;
    sddm.fprintAuth = true;
  };
}
