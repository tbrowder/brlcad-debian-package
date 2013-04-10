TPATH=/usr/brlcad/bin
TMANPATH=/usr/brlcad/share/man

if [ -n "$PATH" ] ; then
  PATH=${PATH}:${TPATH}:
else
  PATH=$TPATH
fi
if [ -n "$MANPATH" ] ; then
  MANPATH=${MANPATH}:${TMANPATH}
else
  MANPATH=${TMANPATH}
fi

export PATH=$PATH:/usr/brlcad/bin
export MANPATH=$MANPATH:/usr/brlcad/share/man
