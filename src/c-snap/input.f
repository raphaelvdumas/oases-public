C   INPUT.FOR
      SUBROUTINE INPUT(*, TITLE, FF, NSECT, MODEN, MAXMSH,
     & ALPHA1, ALPHA2,
     & NINC, NXVAL,
     & C0, C1, Z0, Z1,
     & FLAG, AX, AY, AS, SECD, STORE, SRD,
     & RPROF, BATHY, NDIVP2, MAXPRF, HMAX)


      CHARACTER*3 ALPHA2(6), SUBOPT(5)
      CHARACTER*5 ALPHA1(NOPT), OPTION
      CHARACTER*8 MODEL
      CHARACTER*80 WORD, BLANK, WTEMP
      CHARACTER*80 TITLE

      INTEGER NDIVP2( * )
      INTEGER REREAD, ERROR
      INTEGER FIXDZ, OPTMZ

      REAL FLAG(NOPT,ICF), AX(NOPT,6), AY(NOPT,7), AS(5)
      REAL SRD(NOPT,KSRD,2)
      REAL FF(NFF), BUFFIN(6)
      REAL SECD(NOPT,3)
      REAL STORE(NOPT)
      REAL RPROF(1), BATHY(1)
      REAL MAXRNG

      DOUBLE PRECISION TWOPI, PI, OMEGA
      DOUBLE PRECISION C0(NDEP), C1(NDEP), Z0(NDEP), Z1(NDEP)
      DOUBLE PRECISION CC0, CC1, CMIN, H0, H1

      COMMON /AB/ BETA(-1:3), SCATT(2), C2S, CC0, CC1, C2
      COMMON /APM/ NSMPL, NSMDEF
      COMMON /CF/ ENRCHK, ERRMAX, MAXRNG
      COMMON /CFIELD/ FLDRD(3), PULRD(3)
      COMMON /CONTUR/ CNTR1(4,4)
      COMMON /DFFSN/ DFFSN, DFMIN, DFSTEP
      COMMON /ENRGY/ MATCH
      COMMON /EXPMAX/ TRESH, EPS, RNGMAX, EPSDEF
      COMMON /FACTS/ FACT0, FACT1, FLAGF0, FLAGF1
      COMMON /FLAGG/ PLANE, NOVOL, NOLOSS, NOCYL, LARGE, SUMPL
      COMMON /FRQDEP/ FRQREF, FPOW, FRQDEP
      COMMON /CGAUSS/ GAUSS, TH1, TILT
      COMMON /LUIN/ LUIN, LUWRN, LUCHK
      COMMON /LUNIT/ LUPLP, LUPLT, LUPRT
      COMMON /MESH/ DZH0, DZH1, INPDZ, FIXDZ
      COMMON /MSHIST/ MH0(8), MSED(8), ICOUNT, USEOLD
      COMMON /N/ MINMOD, MAXMOD, MODCUT, HBEAM, BPHVEL
      COMMON /NA/ ND0, ND1, CMIN
      COMMON /NN/ H0BEG, H1BEG, NFREQ
      COMMON /NORM/ N12221, N14241
      COMMON /PARA1/ NFF, MSP, NDEP,NOPT, ICF, KSRD
      COMMON /PARAM1/ IRANGE, IFREQ, JUMP, MODQTY
      COMMON /PARAM3/ IMESH, NMESH, MSHRAT, OPTMZ
      COMMON /MODEL/ MODEL
      COMMON /MODSMP/ MSPH0, MODSED, MSPH1
      COMMON /STARTR/ MODST
      COMMON /TRIGON/ TWOPI, PI, OMEGA

      DATA FLAG1/0.0/
      DATA BLANK/' '/

C
C   ARRAY ALPHA1 CONTAINS THE OPTION CODES.
C
C
C   ALPHA1(1)=  TLRAN
C   ALPHA1(2)=  GROUP
C   ALPHA1(3)=  TLAVR
C   ALPHA1(4)=  TLDEP
C   ALPHA1(5)=  TLAVF
C   ALPHA1(6)=  ANGLE
C   ALPHA1(7)=  PHASE
C   ALPHA1(8)=  CONDR
C   ALPHA1(9)=  CONFR
C   ALPHA1(10)= PROFL
C   ALPHA1(11)= MODES
C   ALPHA1(12)= CONDA
C   ALPHA1(13)= HORWN
C   ALPHA1(14)= PARAM
C   ALPHA1(15)= FIELD
C   ALPHA1(16)= PULSE
C   ALPHA1(17)= CONSV
C   ALPHA1(18)= FREE FOR NEW OPTION
C
C   ARRAY ALPHA2 CONTAINS THE SUB-OPTION CODES
C
C
C   ALPHA2(1)=  '   '
C   ALPHA2(2)=  'PRT'
C   ALPHA2(3)=  'PLT'
C   ALPHA2(4)=  'COL'
C   ALPHA2(5)=  'COH'
C   ALPHA2(6)=  'INC'
C
C   SUBOPT IS THE MATRIX WHERE THE INPUT OPTIONS ARE READ LINE BY LINE
C
C
C   SECD IS THE MATRIX WHICH CONTAINS INFORMATION ABOUT RMIN,RMAX AND DE
C   FOR TLRAN AND TLAVR OPTIONS
C
C
C
C   CNTR1 IS THE MATRIX THAT CONTAINS THE VARIOUS ZMIN, ZMAX
C    AND ZLEV COMBINATIONS FOR CONTOURED REPRESENTATIONS.
C
  105 FORMAT(1H ,//,'  INPUT FREQUENCIES:',/)
  110 FORMAT(1H ,2X,F10.2,' HZ')
  115 FORMAT(1H ,/,'  CALCULATION IS ALLOWED ONLY FOR POSITIVE',
     & ' FREQUENCY VALUES.',/,'  EXECUTION IS TERMINATED.')
  118 FORMAT(1H ,/,'   THE FOLLOWING INPUT FREQUENCY VALUE IS',
     & ' SPECIFIED MORE THEN ONCE: ',F7.2,' HZ',/,'   THE INPUT',
     & ' FREQUENCY IS NOW UNIQUELY SPECIFIED.')
  125 FORMAT(A80)
  140 FORMAT(A5,1X,5(A3,1X))
  160 FORMAT(1H ,//,'  DENSITY OF SEDIMENT LESS THAN OR EQUAL TO ZERO',
     & ' IS NOT ACCEPTED.',/,'  EXECUTION IS TERMINATED.')
  170 FORMAT(1H ,//,'  DENSITY OF BOTTOM LAYER LESS THAN OR EQUAL TO',
     & ' ZERO O IS NOT ACCEPTED.',//,'  EXECUTION IS TERMINATED.')
  220 FORMAT(1H ,/,' MATRIX FLAG  ',/,8X,' Y=1;N=0 ',5(2X,A3,3X))
  240 FORMAT(1H ,A5,1X,F7.0,5F8.0)
  260 FORMAT(1H ,/,' MATRIX SRD ',/,'  OPTION ',A6)
  280 FORMAT(1H ,/,' MATRIX SECD ',/,'          RMIN     RMAX     DELR')
  300 FORMAT(1H ,A5,2X,E9.2,2E11.2)
  380 FORMAT(1H ,/,' MATRIX CNTR1',/,10X,'  ZMIN     ZMAX     ZINC    ')
  400 FORMAT(1H ,A5,3X,3E9.2,F9.0)
  410 FORMAT(1H ,/,' EXECUTION TERMINATED BECAUSE OF ARRAY SIZE',
     & ' LIMITATIONS.')
  415 FORMAT(1H ,//,'  REVISE THE "X" AXIS DEFINITION FOR OPTION "TLAVF"
     & ',/,'  THE NUMBER OF SUBDIVISIONS CANNOT EXCEED', I3,' .')
  416 FORMAT(1X,//,'  WARNING : NO OPTION HAS BEEN SPECIFIED ',/)
  418 FORMAT(1X ,/,'  ERROR : THE TOTAL NUMBER OF MODE SAMPLING POINTS '
     & /,'  ALLOWED FOR THIS SNAP VERSION IS ',I6,/,
     & '  THE PRESENT INPUT RUN STREAM REQUIRES : ',I6,
     & ' SAMPLING POINTS.',/,
     & '  THE EXECUTION IS TERMINATED.')
  420 FORMAT(1H ,//,'  REVISE THE "Y" AXIS DEFINITION FOR OPTION ',A5,'.
     & ',/,'  THE NUMBER OF SUBDIVISIONS CANNOT EXCEED', I3,' .')
  421 FORMAT(1H ,//,'  ZERO FREQUENCY VALUE NOT ALLOWED IN "Y" AXIS',
     & ' FOR OPTION ',A5,/,'  EXECUTION IS TERMINATED.')
  430 FORMAT(1H ,/,' NUMBER OF INPUT FREQUENCIES (NFREQ)= ',I3,/,
     & ' SIZE OF FREQUENCY ARRAY (NFF) =',I2)
  450 FORMAT(1H ,/,' NUMBER OF SOUND SPEED PROFILE DEPTHS IN THE ',/,
     & ' WATER LAYER (ND0) =',I3,/,' SIZE OF ARRAY (NDEP)= ',I3)
  460 FORMAT(1H ,' REVISE THE FOLLOWING INPUT LINE:',/,2X,A5,1X,
     & 5(A3,1X),/,' EXECUTION IS TERMINATED.')
  470 FORMAT(1H ,/,' NUMBER OF SOUND SPEED PROFILE DEPTHS IN THE',/,
     & ' TOP BOTTOM LAYER (ND1)= ',I3,' SIZE OF ARRAY (NDEP)= ',I3)
  500 FORMAT(1H ,' THE MAXIMUM NUMBER OF SOURCE/RECEIVER DEPTH',
     & ' COMBINATIONS',/,' HAS BEEN REACHED. ',/,
     & ' EXECUTION IS TERMINATED.')
  520 FORMAT(1X,' ACCEPTABLE VALUES FOR "MATCH" ARE : ',/,
     & ' 1 for pressure matching. ',/,
     & ' 2 for reduced pressure matching. '/,
     & ' 3 for impedance matching. ')
  600 FORMAT(1H ,//,' SHEAR SPEED IN SECTOR # ',I2,' IS TOO HIGH.',/,
     & ' EXECUTION IS TERMINATED.')
  650 FORMAT(1H ,//,' THE ABSORPTION COEFFICIENT FOR THE SHEAR',
     & ' VELOCITY IN SECTOR # ',I2,' IS TOO HIGH.',/,
     & ' EXECUTION IS TERMINATED.')
  660 FORMAT(1H ,//,' REVISE INPUT SOUND SPEED PROFILE IN THE WATER',
     & ' LAYER ',/,'  IN SECTOR NO. ',I5,'    WITH DEPTH :',F10.3,' m',
     & //,5X,'    DEPTH(m)',4X,'  SOUND SPEED(m/s) ')
  670 FORMAT(1H ,5X,F10.3,9X,F10.3)
  680 FORMAT(1H ,/, ' EXECUTION IS TERMINATED.')
  690 FORMAT(1H ,//,' REVISE INPUT SOUND SPEED PROFILE FOR THE TOP',
     & ' BOTTOM LAYER ',/,'  IN SECTOR NO. ',I5,'    WITH DEPTH :',
     & F10.3,' m',//,5X,'    DEPTH(m)',4X,'  SOUND SPEED(m/s) ')
  692 FORMAT(1H ,///,' **** WARNING FOR OPTION CONFR (only): ',/,
     & '  THIS CODE DOES NOT ALLOW FOR MORE THAN ONE SOURCE/RECEIVER',
     & /,'  DEPTH COMBINATION PER RUN.',/,
     & '  CONFR WILL BE COMPUTED ONLY FOR THE FIRST SD/RD COMBINATION',
     & /,'  FOUND IN THE INPUT RUN STREAM.',/)
  694 FORMAT(1H ,///,' **** WARNING FOR OPTION CONFR (only): ',/,
     & '  THIS CODE DOES NOT ALLOW THE CHOICE OF BOTH COHERENT AND',
     & /,'  INCOHERENT ADDITION OF MODES AT THE SAME TIME.',/,
     & '  IN SUCH A CASE ONLY THE COHERENT CHOICE IS ACCEPTED.',/)
  700 FORMAT(1H ,//,' MAX ALLOWED NUMBER OF INPUT PROFILES IS EXCEEDED',
     & ' (MAX=',I5,').',/,' EXECUTION IS TERMINATED.')
  710 FORMAT(1H ,///,'  REVISE RMIN,RMAX AND/OR XAXIS INPUT VALUES FOR '
     & ,A6,' OPTION.',/
     & /,' CALCULATION:',3X,'MINIMUM RANGE',2X,F11.2,2X,'MAXIMUM RANGE',
     & 3X,F11.2,
     & /,' PLOT AXIS  :',3X,'LEFT HAND VALUE',1X,F11.2,2X,
     & 'RIGHT HAND VALUE ',1X,F11.2,
     & /,'  EXECUTION IS TERMINATED.',//)
  720 FORMAT(1H ,///,'  REVISE FREQUENCY AND/OR XAXIS INPUT VALUES FOR '
     & ,A6,' OPTION.',/
     & /,' CALCULATION:',3X,'MINIMUM FREQ ',2X,F11.2,2X,'MAXIMUM FREQ ',
     & 3X,F11.2,
     &/,'  "X" AXIS  :',3X,'LEFT HAND VALUE',1X,F11.2,2X,
     & 'RIGHT HAND VALUE',1X,F11.2,
     & /,'  EXECUTION IS TERMINATED.',//)
  721 FORMAT(1H ,///,'  REVISE FREQUENCY AND/OR YAXIS INPUT VALUES FOR '
     & ,A6,' OPTION.',/
     & /,' CALCULATION:',3X,'MINIMUM FREQ ',2X,F11.2,2X,'MAXIMUM FREQ ',
     & 3X,F11.2,
     & /,'  "Y" AXIS  :',3X,'MIN VALUE',6X,F11.2,3X,
     & 'MAX VALUE',7X,F11.2,
     &/,'  EXECUTION IS TERMINATED.',//)
  740 FORMAT(1H ,//,'  EXECUTION OF OPTION : "',A5,'" IS NOT ALLOWED ',
     & /,'  FOR LESS THAN TWO FREQUENCIES.')
  739 FORMAT(1X,'    INPUT FREQUENCIES (HZ): ',/)
  741 FORMAT(1X,'  ',I3,')  ','FREQ=',F10.2,/)
  742 FORMAT(1X,'Y AXIS SPECIFICATIONS (HZ):',//,
     & 1X,'FMIN =',F10.2,2X,'FMAX =',F10.2,/)
  820 FORMAT(1H ,//,'  MISSING DEPTH SPECIFICATION FOR OPTION "',A5,
     & '"',/,'  EXECUTION IS TERMINATED.')
  840 FORMAT(1H ,/,'   THE AXES FOR OPTION ',A5,' ARE TOO BIG.',/,'  '
     & ,' MAXIMUM AVAILABLE PAPER SIZE (CM) ALLOWS FOR:',/,
     & '   (AXMAX+7.0,AXMIN+6.0).LE.(',F6.2,',',F6.2,')',/,
     & '   THE ACTUAL AXES LENGTH IS:')
  860 FORMAT(1H ,'  AXMAX ("X" AXIS) =',F8.2,' CM',/,
     & '   AXMIN ("Y" AXIS) =',F8.2,' CM')
  870 FORMAT(1X,//,' *************** ',/,' WARNING :  PLANE GEOMETRY',
     & ' PROBLEM ',/,' *************** ')
  872 FORMAT(1X,//,' ************* ',/,' WARNING :  VOLUME ATTENUATION',
     & ' IS NOT INCLUDED ',/,' ************* ')
  874 FORMAT(1H ,///,' **** WARNING: USING FILES FROM PREVIOUS RUN ****
     & ',//)
  876 FORMAT(1H ,///,' **** ERROR IN READING ',A5,' : ',/,1X,A80,/)
  880 FORMAT(1H ,'  AXMAX ("Y" AXIS) =',F8.2,' CM',/,
     & '   AXMIN ("X" AXIS) =',F8.2,' CM')
C  882 FORMAT(1X,' *** WARNING FROM SUB INPUT : INPDZ IS SET *** ',/,5X,
C     & ' DEPTH INTERVAL ON MESH POINTS (MODE AMPS) : ',F9.2,' m',/)
  882 FORMAT(1X, ' *** WARNING FROM SUB INPUT : INPDZ IS SET *** ',/,
     & '  DZ IN LAYER H0 ON MESH POINTS FOR MODE AMPS ' ,F9.2,/,
     & '  DZ IN LAYER H1 ON MESH POINTS FOR MODE AMPS ' ,F9.2)
C     &,/,
C     & '  THE RATIO AMONG THE SIZE OF ADJACENT MESHES IS SET TO  2. ')
  884 FORMAT(1H ,///,' **** ERROR IN READING NSMPL : ',/,1X,A80,/)
  886 FORMAT(1X, ' *** WARNING FROM SUB INPUT : *** ',/,
     & '  THE RATIO AMONG THE SIZE OF ADJACENT MESHES IS SET TO  2. ')
  888 FORMAT(1H ,///,' **** WARNING: CHECK ON STABILITY OF MEAN ENERGY',
     & ' WILL BE PERFORMED ' )
  890 FORMAT(1H ,//,'  NO OPTION CAN BE SPECIFIED MORE THAN ONCE.',
     &/,'  REVISE OPTION ',A5,' .')
  892 FORMAT(1X,//,' ************* ',/,' WARNING :  LOSSES ARE',
     & ' NOT INCLUDED. ',/,' ************* ')
  894 FORMAT(1H ,///,' **** ERROR IN READING THE FOLLOWING LINE : ',/,
     & 1X,A80,/)
  896 FORMAT(1X,//,' ************* ',/,' WARNING :  MAX TOLERATED',
     & ' ERROR FOR CONVERGENCY CHECK :',E12.3,/,' ************* ')
  898 FORMAT(1X,//,' ************* ',/,' WARNING :  CYLINDRICAL',
     & ' SPREADING IS NOT INCLUDED ',/,' ************* ')
  900 FORMAT(1H ,///,'  REVISE THE NUMBER OF INPUT FREQUENCIES')
  902 FORMAT(1H ,///,' **** WARNING: LARGE PRINT OUT ACTIVATED ****',
     & //)
  906 FORMAT(1H ,///,' **** WARNING: The "SNAP" suboption will be',
     & ' ignored.',/,
     & ' It can be requested only for single profile cases.',//)
  910 FORMAT(1H ,///,'  REVISE MINMOD,MAXMOD')
  915 FORMAT(1X,//,' WARNING: THIS PROGRAM VERSION ALLOWS'
     & ,' FOR A MAXIMUM OF ',I6,' MODES.')
  920 FORMAT(1H ,///,'  REVISE ND,RM (output depths,ACCURACY)')
  930 FORMAT(1H ,///,'  REVISE NUMBER OF SECTORS')
  940 FORMAT(1H ,///,'  REVISE NUMBER OF SAMPLES/MODE ')
  942 FORMAT(1H ,///,'  REVISE NUMBER OF MESHES ')
  944 FORMAT(1H ,///,'  REVISE OUTPUT MESH (IMESH)')
  946 FORMAT(1H ,///,'  WARNING: MAX ALLOWED NUMBER OF MESHES IS ',I3)
  948 FORMAT(1H ,///,'  WARNING: THE OUTPUT MESH CANNOT EXCEED ',
     &               'THE MAX ALLOWED NUMBER OF MESHES')
  950 FORMAT(1H ,///,'  REVISE WATER DEPTH, SCATTERING HEIGHTS,',
     & ' RANGE AND NUMBER OF SUBDIVISIONS.')
  960 FORMAT(1H ,///,'   ERROR DETECTED ON FIRST PROFILE :',/,
     & '   RANGE COORDINATE OF FIRST REGION MUST ALWAYS BE ZERO ',/,
     & '   REVISE THE FOLLOWING INPUT LINE : ',/,A80)
  970 FORMAT(1H ,///,'   ERROR DETECTED ON REGION NO. ',I3,' :',/,
     & '   RANGE COORDINATES MUST FORM A MONOTONIC',
     & ' INCREASING SEQUENCE ',/,
     & '   PREVIOUS RANGE : ',F9.3,/,
     & '   ACTUAL RANGE   : ',F9.3,/,
     & '   LAST INPUT LINE : ',/,1X,A80)
  972 FORMAT(1X,//,' ************* ',/,' WARNING :  DZ ON MODE AMPS',
     & ' WILL BE KEPT CONSTANT OVER RANGE ',/,' ************* ')
  974 FORMAT(1X,//,' ************* ',/,' WARNING :  MODES CARRYING',
     & ' NEGLIGIBLE ENERGY WILL BE DISCARDED.',/,' ************* ')
  976 FORMAT(1X,/,' *** WARNING ***  INCONSISTENT INPUT ',
     & 'SPECIFICATION:'
     & ,/,' THE "HBEAM" OPTION WILL BE IGNORED AND'
     & ,/,' A GAUSSIAN SOURCE FIELD WILL BE PROPAGATED INSTEAD. ')
  978 FORMAT(1X,/,' *** WARNING ***  INCONSISTENT INPUT ',
     & 'SPECIFICATION:'
     & ,/,' THE REQUEST FOR A GAUSSIAN SOURCE WILL BE IGNORED AND'
     & ,/,' THE "HBEAM" OPTION WILL BE COMPUTED INSTEAD.')

C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
C
C       SOURCE PROPERTIES, SAMPLING DEPTH (MSP), ACCURACY (MAXRNG)
C
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

      DO 1020   I=1,NFF
      FF(I)=0.0
 1020 CONTINUE
C
      DO 1040   I=1,NDEP
      C0(I)=0.0
      C1(I)=0.0
      Z0(I)=0.0
      Z1(I)=0.0
 1040 CONTINUE
C
      HMIN=1.0E38
      HMAX=0.0
      H0MAX=0.0
      BPHVEL=0.0
C
      READ(LUIN,'(a)')   TITLE
      READ(LUIN, *, ERR=1100)   NFREQ
      GO TO 1150
 1100 WRITE(LUPRT,900)
      WRITE(LUPRT,680)
      RETURN 1
 1150 CONTINUE
      IF(NFREQ.LE.NFF)   GO TO 1200
      ITEMP=NFF
      WRITE(LUPRT,410)
      WRITE(LUPRT,430) ITEMP,NFREQ
      RETURN 1
C   INPUT FREQUENCIES ARE READ AND ARRANGED TO BE A
C   MONOTONIC INCREASING FUNCTION.
 1200 READ(LUIN,*)(FF(I),I=1,NFREQ)
      IF(NFREQ .EQ. 1)   GO TO 1450
      DO 1300   II=2,NFREQ
      I=II
 1250 CONTINUE
      IF(FF(I) .GT. FF(I-1))   GO TO 1300
      TEMP=FF(I)
      FF(I)=FF(I-1)
      FF(I-1)=TEMP
      I=I-1
      IF(I.GT.1)   GO TO 1250
 1300 CONTINUE
C
C   LOOP TO REMOVE EVENTUAL REPETITIONS OF
C   FREQUENCY VALUES.
C
      I=1
      DO 1400   II=2,NFREQ
      IF(FF(I) .EQ. FF(II))   GO TO 1350
      TEMP=FF(II)
      I=I+1
      FF(I)=TEMP
      GO TO 1400
 1350 WRITE(LUPRT,118) FF(I)
 1400 CONTINUE
      NFREQ=I
 1450 CONTINUE
      IF(FF(1).GT.0.0)   GO TO 1500
      WRITE(LUPRT,105)
      WRITE(LUPRT,110)(FF(I),I=1,NFREQ)
      WRITE(LUPRT,115)
      RETURN 1
 1500 CONTINUE

C      READ(LUIN,*,ERR=1525) MINMOD, MAXMOD, MODCUT
C ___________________________________________________________
      DO 1502   I= 1, 3
 1502 BUFFIN(I)= 0.0
      READ(LUIN, 125, ERR= 1525) WORD
      CALL RFFORM(WORD,80,BUFFIN,1,3,ERROR)
      IF(ERROR .NE. 0)   GO TO 1525
      MINMOD= BUFFIN(1)
      MAXMOD= BUFFIN(2)
      MODCUT= BUFFIN(3)
      IF(MODCUT .EQ. 0)   MODCUT= MAXMOD
C ___________________________________________________________

      MODCUT= MIN(MODCUT,MODEN)
      IF(MINMOD .GT. 0)   GO TO 1530
      MINMOD=1
      GO TO 1530
 1525 WRITE(LUPRT,910)
      WRITE(LUPRT,680)
      RETURN 1
 1530 CONTINUE
C
      IF(MAXMOD .GT. MODEN-2)   THEN
       MAXMOD=MODEN-2
       WRITE(LUPRT,915) MAXMOD
      END IF
C
C      READ(LUIN,*,ERR=1535)FACT0,FACT1
      DO 1532   I= 1, 4
 1532 BUFFIN(I)= 0.0
      READ(LUIN,125) WORD
      CALL RFFORM(WORD,80,BUFFIN,1,4,ERROR)
      IF(ERROR .NE. 0)   GO TO 1535

      FACT0=BUFFIN(3)
      FACT1=BUFFIN(4)
      FLAGF0=0.
      FLAGF1=0.

      IF(BUFFIN(3) .LT. 0.)   THEN
       FLAGF0=1.
       FACT0=1.
      ELSE IF(BUFFIN(3) .EQ. 0.)   THEN
       FACT0=1.
      END IF

      IF(BUFFIN(4) .LT. 0.)   THEN
       FLAGF1=1.
       FACT1=1.
      ELSE IF(BUFFIN(4) .EQ. 0.)   THEN
       FACT1=1.
      END IF

      MAXRNG=BUFFIN(2)
C      MSPH0= JNINT(BUFFIN(1)) + 1
      MSPH0= INT( BUFFIN(1) + 0.500) + 1
      IF(MAXRNG .LT. 1.0E35)   MAXRNG=MAXRNG*1.0E3
C
      GO TO 1540
 1535 WRITE(LUPRT,920)
      WRITE(LUPRT,680)
      RETURN 1
 1540 CONTINUE
C
      WRITE(10)   MINMOD, MAXMOD


C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
C
C                     ENVIRONMENTAL INPUT
C
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

      I= 0
 2800 CONTINUE

      READ(LUIN,125)   WORD
C  IS IT A NUMBER OR A CODE WORD ?
      CALL ISITAN( WORD, *2900)
      BACKSPACE LUIN
      READ(LUIN, *, ERR= 2900) H0
      BACKSPACE LUIN
      READ(LUIN, *, ERR= 2900) DUMMY, SCATT

      IBLANK=INDEX(WORD,'!')
      WTEMP= WORD
      IF(IBLANK .GT. 0)   WTEMP(IBLANK:80)= BLANK(IBLANK:80)
      BUFFIN(4)= 0.0
      BUFFIN(5)= 0.0
      CALL RFFORM(WTEMP,80,BUFFIN,1,5,ERROR)

      IF(ERROR .NE. 0)   THEN
        WRITE(LUPRT,950)
        WRITE(LUPRT,680)
        RETURN 1
      ELSE
        I= I + 1
        IF( I .GT. MAXPRF-1)   THEN
          WRITE(LUPRT,700) MAXPRF-1
          STOP
        END IF
      END IF

      RPROF(I)= BUFFIN(4)
      IF( I .EQ. 1 )    THEN
        IF( RPROF(I) .NE. 0.0 )   THEN
          WRITE(LUPRT,960) WORD
          PRINT 960, WORD
          STOP
        END IF
      ELSE IF( RPROF(I) .LE. RPROF(I-1) )   THEN
        WRITE(LUPRT,970) I, RPROF(I-1), RPROF(I), WORD
        PRINT 970, I, RPROF(I-1), RPROF(I), WORD
        STOP
      END IF
      NDIVP2(I)= BUFFIN(5)
C      READ(LUIN,*) RPROF(I), NDIVP2(I)
C      READ(LUIN,*) H0, SCATT
      IF( H0 .GT. 0.0 )   THEN
        BATHY(I)= H0
        ND0=1
        READ(LUIN,*) Z0(1), C0(1)
        IF(Z0(1) .NE. 0.0)   THEN
         WRITE(LUPRT,660) I, H0
         WRITE(LUPRT,670) (Z0(ID),C0(ID),ID=1,ND0)
         WRITE(LUPRT,680)
         STOP
        END IF
 1750   CONTINUE
        ND0= ND0+1
        IF(ND0 .GT. NDEP)   THEN
         WRITE(LUPRT,410)
         WRITE(LUPRT,450) ND0, NDEP
         STOP
        END IF

        READ(LUIN,*) Z0(ND0), C0(ND0)

        IF( (Z0(ND0) .LT. Z0(ND0-1)) .OR.
     &     ((Z0(ND0)/H0 - 1.0) .GT. 1.0E-05) ) THEN
         WRITE(LUPRT,660) I, H0
         WRITE(LUPRT,670)(Z0(ID),C0(ID),ID=1,ND0)
         WRITE(LUPRT,680)
         STOP
        ELSE
         IF( (ABS(Z0(ND0)/H0 - 1.0) .GT. 1.0E-05))  GO TO 1750
         H0= Z0(ND0)
        END IF
C   THIS POINT IS REACHED WHEN Z0(ND0) IS ASSUMED TO BE EQUAL TO H0
C   CALCULATION OF AVERAGE SOUND SPEED OF WATER LAYER
        CC0=0.
        DO 1860   J=1,ND0-1
 1860   CC0=CC0+((C0(J)+C0(J+1))*(Z0(J+1)-Z0(J)))/2.0
        CC0=CC0/H0

      ELSE
C       The case with H0= 0 is approximated by introducing a 1mm water
C       layer with sound speed derived from the previous region.
        ND0= 2
        H0= 1.0D-3
        Z0(ND0)= H0
        C0(ND0)= C0(1) + 1.0E-3 * (C0(2) - C0(1)) / (Z0(2) - Z0(1)) 
        CC0= 0.5 * (C0(ND0) + C0(1))
      END IF 

      READ(LUIN,*) H1
      IF(H1 .GT. 0.0)   THEN
        BACKSPACE LUIN
        READ(LUIN,125) WORD
        CALL RFFORM(WORD,80,BUFFIN,1,3,ERROR)

C       READ(LUIN,*) H1,R1,BETA(1)
        R1= BUFFIN(2)
        BETA(1)= BUFFIN(3)
        IF(R1 .LE.0.0)   THEN
          WRITE(LUPRT,160)
          RETURN 1
        END IF
        ND1=1
        READ(LUIN,*) Z1(ND1), C1(ND1)
        IF(Z1(1) .NE. 0.0)   THEN
         WRITE(LUPRT,690) I, H1
         WRITE(LUPRT,670) (Z1(ID),C1(ID),ID=1,ND1)
         WRITE(LUPRT,680)
         STOP
        END IF

 1950   CONTINUE
        ND1= ND1+1
        IF(ND1 .GT. NDEP)   THEN
          WRITE(LUPRT,410)
          WRITE(LUPRT,470) ND1, NDEP
          STOP
        END IF

        READ(LUIN,*) Z1(ND1), C1(ND1)
        IF( (Z1(ND1) .LT. Z1(ND1-1)) .OR.
     &     ((Z1(ND1)/H1 - 1.0) .GT. 1.0E-05) ) THEN
          WRITE(LUPRT,690) I
          WRITE(LUPRT,670)(Z1(ID),C1(ID),ID=1,ND1)
          WRITE(LUPRT,680)
          STOP
        ELSE
          IF( (ABS(Z1(ND1)/H1 - 1.0) .GT. 1.0E-05))  GO TO 1950
          H1= Z1(ND1)
        END IF

      ELSE IF(H1 .EQ. 0.0)   THEN
        ND1= 0
        BETA(1)=0.0
        R1=0.0
      ELSE
        WRITE(LUPRT,*) ' NEGATIVE VALUE FOR SEDIMENT DEPTH:',H1
        STOP ' EXECUTION TERMINATED IN SUB input.f '
      END IF

      H0H1= H0+H1
      HMIN= MIN(HMIN,H0H1)
      HMAX= MAX(HMAX,H0H1)
      H0MAX= MAX(H0MAX,SNGL(H0))

      READ(LUIN,*) R2, BETA(2), C2
      IF(R2.GT.0.0)   GO TO 2250
      WRITE(LUPRT,170)
      RETURN 1
 2250 CONTINUE

      IF(I .EQ. 1)   THEN
        H0BEG=H0
        H1BEG=H1
        HTOT=H0H1
      END IF

      READ(LUIN,*) BETA(3), C2S
      IF(C2S.LE.C2*SQRT(0.75))   GO TO 2300
      WRITE(LUPRT,600) I
      RETURN 1
 2300 IF(C2S.GT.0.0)   GO TO 2400
      BETA(3)= 0.0
      GO TO 2500
 2400 IF(BETA(3).LE.0.75*BETA(2)*(C2/C2S)**2)   GO TO 2500
      WRITE(LUPRT,650) I
      RETURN 1
 2500 CONTINUE


C   CALCULATION OF AVERAGE SOUND SPEED OF TOP BOTTOM LAYER
      CC1=0.0
      IF(ND1.GT.0)   THEN
       DO 2600   J=1,ND1-1
 2600  CC1=CC1+((C1(J)+C1(J+1))*(Z1(J+1)-Z1(J)))/2.0
       CC1=CC1/H1
      END IF
C
      WRITE(10) RPROF(I)
      WRITE(10) R1, R2, H0, H1, ND0, ND1
      WRITE(10) (BETA(J), J= 1, 3), SCATT, CC0, CC1
      WRITE(10) (Z0(J), C0(J), J= 1, ND0)
      IF(ND1.GT.0)   WRITE(10) (Z1(J), C1(J), J= 1, ND1)
      WRITE(10)C2,C2S
      GO TO 2800
 2900 CONTINUE
C   THE NDIVP2 VALUE FOR THE LAST ENVIRONMENT IS SET 
C   TO ZERO TO PREVENT INTRODUCING UNNECESSARY RANGE SUBDIVISIONS.
      NDIVP2(I)= 0
      NSECT= I

      REWIND(10)

C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
C
C                     COMPUTATIONAL INPUT
C
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

      REREAD=1
      I=0
 3000 CONTINUE
      DO  3100   J=1,5
 3100 SUBOPT(J)='   '
C
C   CHECK OF INPUT LINE TO DETERMINE REQUESTED OPTION
C
 3120 IF(REREAD .EQ. 0)   READ(LUIN, 125, END= 8000) WORD
      IF( WORD .EQ. BLANK )   GO TO 3120
      REREAD=0
      IF(WORD(1:4) .EQ. '@EOF')   GO TO 8000

      IF(WORD(1:1) .EQ. '!')   THEN
        GO TO 3000

      ELSE IF(WORD(1:5) .EQ. 'PLANE')   THEN
        PLANE=1.0
        WRITE(LUPRT,870)
        GO TO 3000

      ELSE IF(WORD(1:5) .EQ. 'NOVOL')   THEN
        NOVOL=1
        WRITE(LUPRT,872)
        GO TO 3000

      ELSE IF(WORD(1:5) .EQ. 'FRQDP')   THEN
        WORD(1:5)= '     '
        BUFFIN(1)= 0.0
        BUFFIN(2)= 0.0
        CALL RFFORM(WORD,80,BUFFIN,1,2,ERROR)
        IF(ERROR. NE. 0)   THEN
          WORD(1:5)= 'FRQDP'
          WRITE(LUPRT,894) WORD
          WRITE(LUPRT,680)
          RETURN 1
        ELSE
          FRQREF= BUFFIN(1)
          FPOW= BUFFIN(2)
        END IF
        GO TO 3000

      ELSE IF(WORD(1:5) .EQ. 'SUMPL')   THEN
        SUMPL= 1.0
        GO TO 3000

      ELSE IF(WORD(1:5) .EQ. 'MODST')   THEN
C     MODAL STARTER
        MODST= 1
        GO TO 3000

      ELSE IF(WORD(1:5) .EQ. 'FIXDZ')   THEN
C         WRITE(LUPRT,*) ' FIXDZ NOT AVAILABLE '
C         PRINT *,' FIXDZ NOT AVAILABLE '
        FIXDZ=1
        WRITE(LUPRT,972)
        GO TO 3000

      ELSE IF(WORD(1:5) .EQ. 'INPDZ')   THEN
        WORD(1:5)= '     '
        BUFFIN(1)= 0.0
C        BUFFIN(2)= 0.0
        CALL RFFORM(WORD,80,BUFFIN,1,2,ERROR)
        IF(ERROR .NE. 0)   THEN
          WORD(1:5)= 'INPDZ'
          WRITE(LUPRT,876) WORD(1:5), WORD
          WRITE(LUPRT,680)
          RETURN 1
        ELSE
          DZH0= BUFFIN(1)
          DZH1= BUFFIN(2)
          INPDZ= 1
          MSHRAT= 2
          FIXDZ= 1
          WRITE(LUPRT,882) DZH0, DZH1
C          WRITE(LUPRT,882) DZH0
        END IF
        GO TO 3000

      ELSE IF(WORD(1:5) .EQ. 'DFFSN')   THEN
        WORD(1:5)= '     '
        BUFFIN(1)= 0.0
        BUFFIN(2)= 0.0
        CALL RFFORM(WORD,80,BUFFIN,1,2,ERROR)
        IF(ERROR .NE. 0)   THEN
          WORD(1:5)= 'DFFSN'
          WRITE(LUPRT,876) WORD(1:5), WORD
          WRITE(LUPRT,680)
          RETURN 1
        ELSE
          DFMIN= BUFFIN(1)*1.0E3
          DFSTEP= BUFFIN(2)*1.0E3
          DFFSN= 1.0
        END IF
        GO TO 3000

      ELSE IF(WORD(1:5) .EQ. 'OPTMZ')   THEN
        OPTMZ=1
        WRITE(LUPRT,974)
        GO TO 3000

      ELSE IF(WORD(1:5) .EQ. 'NMESH')   THEN
        WORD(1:5)= '     '
        BUFFIN(1)= 0.0
        CALL RFFORM(WORD,80,BUFFIN,1,1,ERROR)
        IF(ERROR. NE. 0)   THEN
          WORD(1:5)= 'NMESH'
          WRITE(LUPRT,876) WORD(1:5), WORD
          WRITE(LUPRT,680)
          RETURN 1
        ELSE
          NMESH= BUFFIN(1)
          IF(NMESH .LE. 0)   THEN
            WRITE(LUPRT,942)
            WORD(1:5)= 'NMESH'
            WRITE(LUPRT,876) WORD(1:5), WORD
            WRITE(LUPRT,680)
            RETURN 1
          ELSE IF(NMESH .GT. MAXMSH)   THEN
            NMESH= MAXMSH
            WRITE(LUPRT,946) NMESH 
          END IF
        END IF
        GO TO 3000

      ELSE IF(WORD(1:5) .EQ. 'IMESH')   THEN
        WORD(1:5)= '     '
        BUFFIN(1)= 0.0
        CALL RFFORM(WORD,80,BUFFIN,1,1,ERROR)
        IF(ERROR. NE. 0)   THEN
          WORD(1:5)= 'IMESH'
          WRITE(LUPRT,876) WORD(1:5), WORD
          WRITE(LUPRT,680)
          RETURN 1
        ELSE
          IMESH= BUFFIN(1)
          IF(IMESH .LE. 0)   THEN
            WRITE(LUPRT,944)
            WORD(1:5)= 'IMESH'
            WRITE(LUPRT,876) WORD(1:5), WORD
            WRITE(LUPRT,680)
            RETURN 1
          ELSE IF(IMESH .GT. MAXMSH)   THEN
            IMESH= MAXMSH
C            WRITE(LUPRT,948) IMESH 
          END IF
        END IF
        GO TO 3000

      ELSE IF(WORD(1:5) .EQ. 'NSMPL')   THEN
        WORD(1:5)= '     '
        BUFFIN(1)= 0.0
        CALL RFFORM(WORD,80,BUFFIN,1,1,ERROR)
        IF(ERROR. NE. 0)   THEN
          WORD(1:5)= 'NSMPL'
          WRITE(LUPRT,884) WORD
          WRITE(LUPRT,680)
          RETURN 1
        ELSE
          NSMPL= BUFFIN(1)
          IF(NSMPL .LE. 0)   THEN
            WRITE(LUPRT,940)
            WORD(1:5)= 'NSMPL'
            WRITE(LUPRT,884) WORD
            WRITE(LUPRT,680)
            RETURN 1
          END IF
        END IF
        GO TO 3000

      ELSE IF(WORD(1:6) .EQ. 'N14241')   THEN
        N14241= 1
        N12221= 0
        GO TO 3000

      ELSE IF(WORD(1:5) .EQ. 'DOUBL')   THEN
        MSHRAT= 2
        WRITE(LUPRT,886)
        GO TO 3000

      ELSE IF(WORD(1:5) .EQ. 'NOLOS')   THEN
        NOLOSS=1
        WRITE(LUPRT,892)
        GO TO 3000

      ELSE IF(WORD(1:5) .EQ. 'CNVRG')   THEN
        WORD(1:5)= '     '
        BUFFIN(1)= 0.0
        CALL RFFORM(WORD,80,BUFFIN,1,1,ERROR)
        IF(ERROR. NE. 0)   THEN
          WORD(1:5)= 'CNVRG'
          WRITE(LUPRT,894) WORD
          WRITE(LUPRT,680)
          RETURN 1
        ELSE
          ENRCHK= 1.0
          WRITE(LUPRT,888)
          ERRMAX= BUFFIN(1)
          WRITE(LUPRT,896) ERRMAX
        END IF
        GO TO 3000

      ELSE IF(WORD(1:5) .EQ. 'MATCH')   THEN
        WORD(1:5)= '     '
        BUFFIN(1)= 0.0
        CALL RFFORM(WORD,80,BUFFIN,1,1,ERROR)
        IF(ERROR. NE. 0)   THEN
          WORD(1:5)= 'MATCH'
          WRITE(LUPRT,894) WORD
          WRITE(LUPRT,680)
          RETURN 1
        ELSE
          MATCH= BUFFIN(1)
          IF( ( MATCH .LT. 1) .OR. ( MATCH .GT. 3 ) )   THEN
           WRITE(LUPRT,520)
           PRINT 520
           WRITE(LUPRT,680)
           RETURN 1
          END IF          
        END IF
        GO TO 3000

      ELSE IF(WORD(1:5) .EQ. 'HBEAM')   THEN
        WORD(1:5)= '     '
        BUFFIN(1)= 0.0
        CALL RFFORM(WORD,80,BUFFIN,1,1,ERROR)
        IF(ERROR. NE. 0)   THEN
          WORD(1:5)= 'HBEAM'
          WRITE(LUPRT,894) WORD
          WRITE(LUPRT,680)
          RETURN 1
        ELSE
          HBEAM= BUFFIN(1)
          MINMOD= 1
          MAXMOD= MODEN-2
          MODCUT= MODEN-2
          IF( GAUSS .GT. 0.0 )   THEN
            GAUSS= 0.0
            TH1= 0.0
            TILT= 0.0
            WRITE(LUPRT,978)
          END IF
        END IF
        GO TO 3000

      ELSE IF(WORD(1:5) .EQ. 'GAUSS')   THEN
        WORD(1:5)= '     '
        BUFFIN(1)= 0.0
        CALL RFFORM(WORD,80,BUFFIN,1,2,ERROR)
        IF(ERROR. NE. 0)   THEN
          WORD(1:5)= 'GAUSS'
          WRITE(LUPRT,894) WORD
          WRITE(LUPRT,680)
          RETURN 1
        ELSE
          GAUSS= 1.0
          TH1= BUFFIN(1)
          TILT= BUFFIN(2)
          MINMOD= 1
          MAXMOD= MODEN-2
          MODCUT= MODEN-2
          IF( HBEAM .GT. 0.0)   THEN
            WRITE(LUPRT,976)
            HBEAM= 0.0
          END IF
        END IF
        GO TO 3000

      ELSE IF(WORD(1:5) .EQ. 'NOCYL')   THEN
        NOCYL= 1
        WRITE(LUPRT,898)
        GO TO 3000

      ELSE IF(WORD(1:5) .EQ. 'LARGE')   THEN
        LARGE= 1
        WRITE(LUPRT,902)
        GO TO 3000

      ELSE IF(WORD(1:5) .EQ. 'SNAP ')   THEN
        IF( NSECT .EQ. 1 )   THEN
          MODEL(1:6)='SNAP  '
        ELSE
          WRITE(LUPRT,906)
        END IF
        GO TO 3000

      END IF

      READ(WORD,140)   OPTION,(SUBOPT(I),I=1,5)
      CALL CHKOPT(I, OPTION, SUBOPT, ALPHA1, ALPHA2,
     &            FLAG, FLAG1, OUTPUT, *3500)
      RETURN 1

 3500 CONTINUE
      WORD=BLANK
 3520 READ(LUIN, 125, END= 3540)   WORD
      GO TO 3560
 3540 CONTINUE
      WORD(1:4)= '@EOF'
 3560 CONTINUE
      IF( WORD .EQ. BLANK )   GO TO 3520
      IF(WORD(1:4) .EQ. '@EOF')   THEN
       REREAD=1
       GO TO 7000
      END IF
      CALL RFFORM(WORD,80,DUMMY,1,1,ERROR)

      IF(ERROR .GT. 0)   THEN
C     INPUT LINE BEGINS WITH AN ALPHABETICAL CHARACTER.
C     THE CASES ARE: NEW OPTION, PLOT AXIS, FILE REQUEST, DEPTH INTERVAL
       CALL RDALFA(I,REREAD,WORD,ALPHA1,AX,AY,AS,STORE,
     & *7000,*3500)
       RETURN 1

      ELSE

       CALL RDNUMB( I, WORD, REREAD, ALPHA1, H1BEG, H0BEG,
     & SECD, SRD, LUIN, *7000, *3600)
       RETURN 1
 3600  CONTINUE
C      READING SOURCE/RECEIVER DEPTHS
       CALL RDSD(I,WORD,REREAD,LUIN,ALPHA1,HTOT,HMAX,
     & SRD,*7000)
       RETURN 1

      END IF
 7000 CONTINUE

      CALL REVISE(I,FF,NFREQ,ALPHA1,
     & H0,H0MAX,H1,H0BEG,
     & NINC,NXVAL,
     & FLAG,AX,AY,SECD,SRD,HMAX,RPROF(NSECT),NSECT,*3000)
       RETURN 1

 8000 CONTINUE

      IF( (I .EQ. 0) .AND. (ENRCHK .LT. 1.0) )   THEN
       WRITE(LUPRT,416)
       RETURN 1
      END IF


      IF(MSPH0 .EQ. 1)   MSPH0=51
      MSPZ=MSPH0
C      IF(MSPZ .LE. MSP)   THEN
        MSP=MSPZ
C      ELSE
C       WRITE(LUPRT,418) MSP,MSPH0
C       RETURN 1
C      END IF


C   CHECK ON NUMBER OF
C   SOURCE RECEIVER DEPTHS COMBINATIONS, AND 
C   OF MINIMUM NUMBER OF FREQUENCIES FOR 
C   'CONFR', 'CONDA' AND 'HORWN' OPTIONS.
C   
      DO 7600   IOP= 1, 3

      IF(IOP .EQ. 1)   THEN
        I=9
C       CASE WHEN ALPHA1(I)= 'CONFR'
C       THE NUMBER OF SOURCE/RECEIVER DEPTHS IS LIMITED TO ONE AND
C       THE CHOICE OF MODE ADDITION TO EITHER COHERENT OR (EXCLUSIVE OR)
C       INCOHERENT TYPE. THE LIMITATION IS DUE TO THE PROBLEM ASSOCIATED
C       WITH THE NAMING OF THE OUTPUT FILES AND THE SORTING OF THE
C       INTERMEDIATE OUTPUT FILES. WITH THE PRESENT STRUCTURE
C       OPTION CONFR CAN HAVE ONLY ONE SET OF OUTPUT FILES :
C       "INPUTFILE"_FR.CDR and "INPUTFILE"_FR.BDR.
        IF(FLAG(I,1) .GT. 0.0)   THEN
          IF( SRD(I,2,1) .GT. 0.)   THEN
            WRITE(LUPRT, 692)
            PRINT 692
            DO 7520   IS= 2, KSRD
            SRD(I,IS,1)= 0.0
            SRD(I,IS,2)= 0.0
 7520       CONTINUE
          END IF
          IF( (FLAG(I,5) + FLAG(I,6)) .GT. 1.0)   THEN
            WRITE(LUPRT, 694)
            PRINT 694
            FLAG(I,6)= 0.0
          END IF
          KFREQ= 0
          DO 7550   K= 1, NFREQ
          IF((FF(K) .GE. AY(I,1)).AND.(FF(K) .LE. AY(I,2)))
     &    KFREQ= KFREQ+1
 7550     CONTINUE
          IF(KFREQ.GE.2)   GO TO 7600
          WRITE(LUPRT,740) ALPHA1(I)
          WRITE(LUPRT,739)
          DO 7551 K= 1, NFREQ
          WRITE(LUPRT,741) K, FF(K)
 7551     CONTINUE
          WRITE(LUPRT,742) AY(I,1),AY(I,2)
          FLAG1=-1.0
        END IF
      ELSE IF(IOP .EQ. 2)   THEN
        I=12
C       CASE WHEN ALPHA1(I)= 'CONDA'
      ELSE IF(IOP .EQ. 3)   THEN
        I=13
C       CASE WHEN ALPHA1(I)= 'HORWN'
      END IF
 7600 CONTINUE

      IF(FLAG1 .GT. -1.0)   GO TO 7900
      WRITE(LUPRT,680)
      RETURN 1
 7900 CONTINUE

      RETURN
      END
