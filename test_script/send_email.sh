#!/bin/bash

send_email()
{
	# Write Contents
	contents="To: ultractgm@gmail.com\r\n"
	contents="${contents}From: ultractgm@gmail.com\r\n"
	contents="${contents}Subject: Result of Kernel Tailoring Test\r\n\r\n"
	#contents="${contents}MIME-Version: 1.0\r\n"
	#contents="${contents}Content-Type: text/plain; charset=UTF-8\r\n\r\n"
        contents="${contents}$1\r\n"

	# Send Contents
	echo -e "$contents" | ssmtp ultractgm@gmail.com
}

#send_email "This is Test!!!"

send_email "Tailored Kerneal Testing Progress: A Quater Done!\r\nRemaining Configs\: $num_of_conf\r\nTotal $(($SECONDS / 60)) Minutes and $(($SECONDS % 60)) Seconds Elapsed...\r\n"

#send_email "Kernel Tailoring Finished!\r\nTotal $(($SECONDS / 60)) Minutes and $(($SECONDS % 60)) Seconds Elapsed... \r\n $final_config_result \r\n"

