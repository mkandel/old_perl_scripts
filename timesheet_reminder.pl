#!/bin/bash

RCVRS="marc.kandel@sap.com"
echo "It's `date` ... Do your timesheet!!!
https://www.cditime.com/
User Id: 3004509732" > /tmp/atch.mkandel

mail -s "Timesheet Due" ${RCVRS} < /tmp/atch.mkandel

rm /tmp/atch.mkandel

exit 0
