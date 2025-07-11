C    DEFSD.FOR

      SUBROUTINE DEFSD( ALPHA1,
     & REORD2, FLAG, SRD, SECD, AY, NOPT, ICF, KSRD,
     & QRNG, NRANGE, QRD, MSPMAX, ZSTEP,
     & RNGTMP, RDTMP,
C    OUTPUT PARAMETERS:
     & SD, OPTSD,
     & RNG, NRNGC,
     & RDC, NRDC )

      INTEGER OPTSD(NOPT), REORD2(NOPT)
      INTEGER NRNG(2), NRD(2)

      CHARACTER*5 ALPHA1(NOPT)

      REAL  FLAG(NOPT,ICF), SRD(NOPT,KSRD,2), SECD(NOPT,3)
      REAL AY(NOPT,7)
      REAL QRNG(NRANGE,2), RNG(NRANGE), RNGTMP( * )
      REAL QRD(MSPMAX,2), RDC( * ), RDTMP( * )

      COMMON /LUNIT/ LUPLP, LUPLT, LUPRT

  100 FORMAT(1X,' WARNING : TO MAINTAIN UNIFORM DEPTH SAMPLING ON',
     &  /,'  PRINT/PLOT OUTPUT THE MINIMUM DEPTH FOR OPTIONS "TLDEP"',
     &  /,'  AND/OR "CONDR" IS ADJUSTED TO COINCIDE WITH THE CLOSEST',
     &  /,'  INTEGER MULTIPLE OF THE SAMPLING DEPTH. ',/)
  200 FORMAT(1X,' WARNING : TO MAINTAIN UNIFORM DEPTH SAMPLING ON',
     &  /,'  PRINT/PLOT OUTPUT THE MAXIMUM DEPTH FOR OPTIONS "TLDEP"',
     &  /,'  AND/OR "CONDR" IS ADJUSTED TO COINCIDE WITH THE CLOSEST',
     &  /,'  INTEGER MULTIPLE OF THE SAMPLING DEPTH. ',/)
  300 FORMAT(1X, '     MAX ALLOWED NUMBER OF RANGE STEPS FOR A SINGLE',
     & ' OPTION IS ',I5,/,
     &           '     RANGE STEP IS MODIFIED TO', F9.2, ' m')
  320 FORMAT(1X, '    FATAL ERROR: MAX ALLOWED CUMULATIVE NUMBER',
     & ' OF DIFFERENT RANGE STEPS',/,'     IS EXCEEDED (',I5,').',/,
     & '     PROBLEM DETECTED FOR OPTION(S) AT SOURCE DEPTH ',F9.2,
     & ' m .',/,
     & '     EXECUTION IS TERMINATED.')
  340 FORMAT(1X,'    FATAL ERROR: MAX ALLOWED CUMULATIVE NUMBER',
     & ' OF DIFFERENT RECEIVERS',/,
     &          '     IN THE WATER-SEDIMENT INTERVAL IS EXCEEDED FOR',
     & ' THE OPTION(S)',/,
     &          '     AT SOURCE DEPTH ',F8.1,' m .',/,
     &          '     MAX ALLOWED NUMBER:  ',I6,/,
     &          '     REQUIRED NUMBER .GE. ',I6,/,
     &          '     EXECUTION IS TERMINATED.',//)


C     SEARCHING FOR A SOURCE DEPTH
      DO 2300   K= 1, NOPT
      IOP= REORD2(K)
      IF(FLAG(IOP,1) .GT. 0.0)   THEN
C           TLRAN GROUP TLAVR TLDEP TLAVF ANGLE PHASE CONDR CONFR PROFL
C           MODES CONDA HORWN PARAM FIELD PULSE CONSV
      GO TO(2001, 2300, 2300, 2001, 2300, 2300, 2300, 2001, 2001, 2300,
     &      2300, 2300, 2300, 2300, 2300, 2300, 2300), IOP
 2001 CONTINUE
      DO 2200   ISD= 1, KSRD
      SD= SRD(IOP,ISD,1)
      IF( SD .GT. 0.0 )   GO TO 2400
 2200 CONTINUE
      END IF
 2300 CONTINUE
      SD= 0.0
      ICOUNT= 0
      NRNG(1)= 0
      NRNG(2)= 0
      NRNGC= 0
      NRD(1)= 0
      NRD(2)= 0
      NRDC= 0
      RETURN
 2400 CONTINUE


      DO 2500   IR= 1, 2*NRANGE
      RNGTMP(IR)= 0.0
 2500 CONTINUE
      DO 2600   IY= 1, 2*MSPMAX
      RDTMP(IY)= 0.0
 2600 CONTINUE

      TOL= 1.0E-5
      ICOUNT= 0
      NRNG(1)= 0
      NRNG(2)= 0
      NRNGC= 0
      NRD(1)= 0
      NRD(2)= 0
      NRDC= 0

C     BUILDING THE RANGE AND THE RECEIVER DEPTH ARRAYS
      DO 3300   K= 1, NOPT
      IOP= REORD2(K)
      IF(FLAG(IOP,1) .GT. 0.0)   THEN
C            TLRAN GROUP TLAVR TLDEP TLAVF ANGLE PHASE CONDR CONFR PROFL
C            MODES CONDA HORWN PARAM FIELD PULSE CONSV
       GO TO(3001, 3300, 3300, 3004, 3300, 3300, 3300, 3004, 3001, 3300,
     &       3300, 3300, 3300, 3300, 3300, 3300, 3300), IOP

 3001 CONTINUE
C      PRINT *,' LAB 3001, SD',SD
      OPTSD(IOP)= 0
      DO 1216   ISD= 1, KSRD
      IF( ABS(SRD(IOP,ISD,1)/SD - 1.0) .LT. 1.0E-5)   THEN
        SRD(IOP,ISD,1)= -SD

        IF(OPTSD(IOP) .EQ. 0)   THEN
          ICOUNT= ICOUNT + 1
          INEW= MOD(ICOUNT,2) + 1
          IOLD= MOD(ICOUNT+1,2) + 1

C         SAVING RESULT OF PREVIOUSLY JOINED ARRAYS

          NRNG(IOLD)= NRNGC
          DO 1418   I= 1, NRNGC
          QRNG(I, IOLD)= RNGTMP(I)
 1418     CONTINUE

          NRD(IOLD)= NRDC
          DO 1420   I= 1, NRDC
          QRD(I, IOLD)= RDTMP(I)
 1420     CONTINUE
          NRD(INEW)= 1
          OPTSD(IOP)= ISD
          QRD(NRD(INEW),INEW)= SRD(IOP,ISD,2)
        ELSE
C         REPETITION ?
          DO 1422   I1= 1, NRD(INEW)
          IF(QRD(I1, INEW) .EQ. SRD(IOP,ISD,2))   GO TO 1442
 1422     CONTINUE 
          NRD(INEW)= NRD(INEW) + 1
          QRD(NRD(INEW), INEW)= SRD(IOP,ISD,2)
          IF(QRD(NRD(INEW), INEW) .LT. QRD(NRD(INEW)-1,INEW))   THEN
C         SORTING THE INPUT SEQUENCE
            DO 1430   IRD= 1, NRD(INEW)-1
            IF(SRD(IOP,ISD,2) .LT. QRD(IRD,INEW))   THEN
              DO 1428   I1= NRD(INEW), IRD+1, -1
              QRD(I1, INEW)= QRD(I1-1, INEW)
 1428         CONTINUE
              QRD(IRD,INEW)= SRD(IOP,ISD,2)
              GO TO 1440
            END IF
 1430       CONTINUE
 1440       CONTINUE
          END IF
 1442     CONTINUE
        END IF

      END IF
 1216 CONTINUE

      IF( OPTSD(IOP) .GT. 0)   THEN
C       RANGE ARRAY:
        IF( SECD(IOP,3) .EQ. 0.0 )   THEN
          NR= 1
        ELSE
          NR= INT((SECD(IOP,2)-SECD(IOP,1))/SECD(IOP,3) + 0.5 ) + 1
        END IF
        IF( NR .GT. NRANGE )   THEN
          NR= NRANGE
          SECD(IOP,3)= ( SECD(IOP,2) - SECD(IOP,1) ) / ( NR - 1 )
          WRITE(LUPRT,*) ' *** WARNING FOR OPTION "TLRAN" : '
          WRITE(LUPRT,300)  NRANGE, SECD(IOP,3)
        END IF

        DO 1002   IR = 1, NR
        QRNG( IR, INEW ) = SECD(IOP,1) + ( IR - 1 ) * SECD(IOP,3)
 1002   CONTINUE
        NRNG(INEW)= NR

          IF( NRNG(INEW) .GT. NRANGE .OR.
     &        NRNG(IOLD) .GT. NRANGE     )   THEN
            PRINT 320, NRANGE, SD
            WRITE(LUPRT,320) NRANGE, SD
            STOP
          END IF
          CALL JOIN(QRNG(1,INEW), QRNG(1,IOLD), RNGTMP,
     &                 NRNG(INEW), NRNG(IOLD), NRNGC, TOL )

          IF( NRD(INEW) .GT. MSPMAX .OR.
     &        NRD(IOLD) .GT. MSPMAX     )   THEN
            PRINT 340, SD, MSPMAX, MAX(NRD(INEW),NRD(IOLD))
            WRITE(LUPRT,340) SD, MSPMAX, MAX(NRD(INEW),NRD(IOLD))
            STOP
          END IF
          CALL JOIN(QRD(1,INEW), QRD(1,IOLD), RDTMP,
     &                 NRD(INEW), NRD(IOLD), NRDC, TOL )

      END IF
      GO TO 3300



 3004 CONTINUE
C      PRINT *,' LAB 3004, SD, ICOUNT ',SD,ICOUNT
      OPTSD(IOP)= 0

      DO 1416   ISD= 1, KSRD
      IF( ABS(SRD(IOP,ISD,1)/SD - 1.0) .LT. 1.0E-5)   THEN

        ICOUNT= ICOUNT + 1
        INEW= MOD(ICOUNT,2) + 1
        IOLD= MOD(ICOUNT+1,2) + 1

C       SAVING RESULT OF PREVIOUSLY JOINED ARRAYS

        NRNG(IOLD)= NRNGC
        DO 2418   I= 1, NRNGC
        QRNG(I, IOLD)= RNGTMP(I)
 2418   CONTINUE

        NRD(IOLD)= NRDC
        DO 2420   I= 1, NRDC
        QRD(I, IOLD)= RDTMP(I)
 2420   CONTINUE

        OPTSD(IOP)= ISD
        SRD(IOP,ISD,1)= -SD

        IRDMIN= AY(IOP,6)/ZSTEP + 1
        IRDMAX= INT( AY(IOP,7)/ZSTEP + 0.5 ) + 1

        IF(AY(IOP,1) .GT. 0.0)   THEN
          ZTEMP= (IRDMIN-1) * ZSTEP
          IF(ABS( ZTEMP/AY(IOP,6) - 1.0 ) .GT. 1.0E-5) WRITE(LUPRT,100)
        END IF
        ZTEMP= (IRDMAX-1) * ZSTEP
        IF( ABS(ZTEMP/AY(IOP,7) - 1.0 ) .GT. 1.0E-5) WRITE(LUPRT,200)

        AY(IOP,6)= (IRDMIN-1) * ZSTEP
        AY(IOP,7)= (IRDMAX-1) * ZSTEP

        NRD(INEW)= IRDMAX - IRDMIN + 1
        DO 3204 IZ= 1, NRD(INEW)
        QRD(IZ, INEW)= AY(IOP,6) + (IZ-1)*ZSTEP
 3204   CONTINUE


C       RANGE ARRAY:
        IF( SECD(IOP,3) .EQ. 0.0 )   THEN
          NR= 1
        ELSE
          NR= INT((SECD(IOP,2)-SECD(IOP,1))/SECD(IOP,3) + 0.5 ) + 1
        END IF
        IF( NR .GT. NRANGE )   THEN
          NR= NRANGE
          SECD(IOP,3)= ( SECD(IOP,2) - SECD(IOP,1) ) / ( NR - 1 )
          WRITE(LUPRT,*) ' *** WARNING FOR OPTION ', ALPHA1(IOP)
          WRITE(LUPRT,300)  NRANGE, SECD(IOP,3)
        END IF
        DO 1014   IR = 1, NR
        QRNG( IR, INEW ) = SECD(IOP,1) + ( IR - 1 ) * SECD(IOP,3)
 1014   CONTINUE
        NRNG(INEW)= NR

          IF( NRNG(INEW) .GT. NRANGE .OR.
     &        NRNG(IOLD) .GT. NRANGE     )   THEN
            PRINT 320, NRANGE, SD
            WRITE(LUPRT,320) NRANGE, SD
            STOP
          END IF
          CALL JOIN(QRNG(1,INEW), QRNG(1,IOLD), RNGTMP,
     &                 NRNG(INEW), NRNG(IOLD), NRNGC, TOL )

          IF( NRD(INEW) .GT. MSPMAX .OR.
     &        NRD(IOLD) .GT. MSPMAX     )   THEN
            PRINT 340, SD, MSPMAX, MAX(NRD(INEW),NRD(IOLD))
            WRITE(LUPRT,340) SD, MSPMAX, MAX(NRD(INEW),NRD(IOLD))
            STOP
          END IF
          CALL JOIN(QRD(1,INEW), QRD(1,IOLD), RDTMP,
     &                 NRD(INEW), NRD(IOLD), NRDC, TOL )
        GO TO 3300
      END IF
 1416 CONTINUE

      GO TO 3300

C 30...  LABEL FOR FUTURE COMPUTATIONAL OPTIONS

      END IF

 3300 CONTINUE


        IF( MAX(NRNGC,NRNG(INEW)) .GT. NRANGE )   THEN
          PRINT 320, NRANGE, SD
          WRITE(LUPRT,320) NRANGE, SD
          STOP
        END IF

        IF( MAX(NRDC,NRD(INEW)) .GT. MSPMAX )   THEN
          PRINT 340, SD, MSPMAX, MAX(NRDC,NRD(INEW))
          WRITE(LUPRT,340) SD, MSPMAX, MAX(NRDC,NRD(INEW))
          STOP
        END IF

      IF(ICOUNT .EQ. 1)   THEN
        NRNGC= NRNG(INEW)
        DO 4200   I= 1,NRNGC
        RNG(I)= QRNG(I, INEW)
 4200   CONTINUE
        NRDC= NRD(INEW)
        DO 4400   I= 1,NRDC
        RDC(I)= QRD(I, INEW)
 4400   CONTINUE

      ELSE

        DO 4600   I= 1,NRNGC
        RNG(I)= RNGTMP(I)
 4600   CONTINUE
        DO 4800   I= 1,NRDC
        RDC(I)= RDTMP(I)
 4800   CONTINUE

      END IF

      RETURN
      END
