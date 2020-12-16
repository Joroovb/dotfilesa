# Defined in - @ line 1
function mediaserver --wraps='ssh joris@192.168.1.203' --description 'alias mediaserver ssh joris@192.168.1.203'
  ssh joris@192.168.1.203 $argv;
end
