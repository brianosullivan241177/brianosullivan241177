SELECT
        Clinician = PR.NAME_FULL_FORMATTED
        , Clinician_Free_Text = PP.PROC_FT_PRSNL
        , P.PROCEDURE_NOTE
        , P.PROC_DT_TM
        ;, E.ORGANIZATION_ID
        , MRN = PA.ALIAS
        ;, PA.ALIAS_POOL_CD
        ;, PA_ALIAS_POOL_DISP = UAR_GET_CODE_DISPLAY(PA.ALIAS_POOL_CD)
        ;, Procedure_Active_Ind= P.ACTIVE_IND
        ;, PP.ACTIVE_IND
        ;, E.ACTIVE_IND
        ;, Personnel_Active_Ind = PR.ACTIVE_IND
        ;, P.END_EFFECTIVE_DT_TM
        ;, Person_Alias_Indicator = PA.ACTIVE_IND
        ;, PE.ACTIVE_IND
        , PE.BIRTH_DT_TM
        ;, PP.END_EFFECTIVE_DT_TM
        , AGE_YEARS = datetimediff(P.PROC_dt_tm, pe.birth_dt_tm ,10)

FROM
        PROCEDURE   P
        , PROC_PRSNL_RELTN   PP
        , PRSNL   PR
        , ENCOUNTER   E
        , PERSON   PE
        , PERSON_ALIAS   PA

PLAN P WHERE P.PROC_DT_TM > CNVTDATETIME("01-APR-2026 00:00:00")
AND P.PROC_DT_TM < CNVTDATETIME("30-APR-2026 23:59:59")
AND P.END_EFFECTIVE_DT_TM > CNVTDATETIME("30-DEC-2100 23:59:59")
AND P.SUPPRESS_NARRATIVE_IND != 1
and p.active_ind = 1

JOIN PP WHERE PP.PROCEDURE_ID = outerjoin(P.PROCEDURE_ID)
and PP.PROC_PRSNL_RELTN_CD != 1207

JOIN PR WHERE PR.PERSON_ID = outerjoin(PP.PRSNL_PERSON_ID)

JOIN E WHERE E.ENCNTR_ID = P.ENCNTR_ID
AND E.ORGANIZATION_ID = 40024 ;CUMH Hospital

JOIN PE WHERE PE.PERSON_ID = E.PERSON_ID
AND PE.BIRTH_DT_TM > cnvtlookbehind("1,Y") ;Less than 1 years of age

JOIN PA WHERE PA.PERSON_ID = PE.PERSON_ID
;and pa.person_id = 14019340
AND PA.ALIAS_POOL_CD = 18991198 ;South MRN
AND PA.END_EFFECTIVE_DT_TM = cnvtdatetime("31-dec-2100"); If this code isnt there then merged mrns will appear too
AND PA.ACTIVE_IND=1

ORDER BY
        P.PROC_DT_TM,
        AGE_YEARS

WITH MAXREC = 1000, NOCOUNTER, SEPARATOR=" ", FORMAT(DATE, "DD-MM-YYYY"), TIME=30