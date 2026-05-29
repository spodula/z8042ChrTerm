;*****************************************************************
;IDEDos extension calls from 
; Https://worldofspectrum.org/zxplus3e/idedos.html
;*****************************************************************
;Miscellaneous calls
IDE_VERSION:            equ  $00A0
IDE_DRIVE:              equ  $00A9
IDE_SNAPLOAD:           equ  $00FD
IDE_ACCESS_DATA:        equ  $019f
IDE_IDENTIFY:           equ  $01a2
IDE_PARTITIONS:         equ  $01a5

;Swap partition services
IDE_SWAP_OPEN:          equ  $00D9
IDE_SWAP_CLOSE:         equ  $00DC
IDE_SWAP_OUT:           equ  $00DF
IDE_SWAP_IN:            equ  $00E2
IDE_SWAP_EX:            equ  $00E5
IDE_SWAP_POS:           equ  $00E8
IDE_SWAP_MOVE:          equ  $00EB
IDE_SWAP_RESIZE:        equ  $00EE

;Data partition access
IDE_PARTITION_NEW:      equ  $00B8
IDE_PARTITION_INIT:     equ  $00BB
IDE_PARTITION_READ:      equ  $00C4
IDE_PARTITION_WRITE:    equ  $00C7
IDE_PARTITION_WINFO:    equ  $00CA
IDE_PARTITION_GETINFO:  equ  $00D3
IDE_PARTITION_SETINFO:  equ  $00D6
IDE_PARTITION_OPEN:     equ  $00CD
IDE_PARTITION_CLOSE:    equ  $00D0
IDE_SECTOR_READ:        equ  $00AC
IDE_SECTOR_WRITE:       equ  $00AF

;Partition management
IDE_PARTITION_FIND:     equ  $00B5
IDE_PARTITION_ERASE:    equ  $00BE
IDE_PARTITION_RENAME:   equ  $00C1
IDE_FORMAT:             equ  $00B2

; Drive mappings
IDE_DOS_MAP:            equ  $00F1
IDE_DOS_UNMAP:          equ  $00F4
IDE_DOS_MAPPING:        equ  $00F7
IDE_DOS_UNPERMANENT:    equ  $00FA

;Streams and channels
IDE_STREAM_OPEN:        equ  $0056
IDE_STREAM_CLOSE:       equ  $0059
IDE_STREAM_IN:          equ  $005c
IDE_STREAM_OUT:         equ  $005f
IDE_STREAM_PTR:         equ  $0062

;Internal calls
IDE_INTERFACE:          equ  $00A3
IDE_INIT:               equ  $00A6

;calls for ResiDos packages that implement filesystems
IDE_FS_UNIT:            equ  $01a8
IDE_FS_DRIVE:           equ  $01ab
IDE_FS_FILE:            equ  $01ae
IDE_PATH:               equ  $01b1

