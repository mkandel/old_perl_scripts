#!/bin/sh

RCVRS="mkandel@aprisma.com dfrye@aprisma.com ggentry@aprisma.com"

echo "It's `date` ... Do your status report!!!" > /tmp/atch.mkandel

/usr/ucb/mail -s "Status Report Due" ${RCVRS} < /tmp/atch.mkandel

rm /tmp/atch.mkandel

exit 0
