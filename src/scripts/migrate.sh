#!/usr/bin/env bash
user=root
password=admin
host=mysql

es_host=es:9200
es_index=melbdatathon2017
es_type=transactions

influx_host=influx:8086
influx_db=melbdatathon2017

max=279201
start=0
end=25
step=25
document=1

echo "[" > ./errors.json
while [ $start -lt $max ]
do
    end=$(( end > max ? max : end ))
    mysql melbdatathon2017 -h$host -u$user -p$password -B -N -s <<<"
    SELECT
        t.Patient_ID AS patientId,
        p.gender,
        p.year_of_birth AS birthYear,
        p.postcode AS patientPostCode,
        t.Store_ID AS storeId,
        s.StateCode AS storeStateCode,
        s.postcode AS storePostCode,
        t.Prescriber_ID AS prescriberId,
        t.Drug_ID AS drugId,
        t.Drug_Code AS drugCode,
        t.SourceSystem_Code AS sourceSystemCode,
        t.Prescription_Week AS prescriptionWeek,
        t.Dispense_Week AS dispenseWeek,
        t.NHS_Code AS NHSCode,
        t.IsDeferredScript AS isDeferredScript,
        t.Script_Qty AS scriptQty,
        t.PatientPrice_Amt AS patientPriceAmount,
        t.WholeSalePrice_Amt AS wholesalePriceAmount,
        t.GovernmentReclaim_Amt AS governmentReclaimAmount,
        t.RepeatsTotal_Qty AS repeatsTotalQty,
        t.Dispensed_Qty AS dispensedQty,
        t.RepeatsLeft_Qty AS repeatsLeftQty,
        t.MaxDispense_Qty AS maxDispenseQty,
        t.StreamlinedApproval_Code AS streamlinedApprovalCode,
        d.MasterProductID AS masterProductId,
        d.MasterProductFullName AS masterProductFullName,
        d.BrandName AS brandName,
        d.FormCode AS formCode,
        d.StrengthCode AS strengthCode,
        d.PackSizeNumber AS packSizeNumber,
        d.GenericIngredientName AS genericIngredientName,
        d.EthicalSubCategoryName AS ethicalSubCategoryName,
        d.EthicalCategoryName AS ethicalCategoryName,
        d.ManufacturerCode AS manufacturerCode,
        d.ManufacturerName AS manufacturerName,
        d.ManufacturerGroupID AS manufacturerGroupId,
        d.ManufacturerGroupCode AS manufacturerGroupCode,
        d.ChemistListPrice AS chemistListPrice,
        d.ATCLevel1Code,
        a.ATCLevel1Name,
        d.ATCLevel2Code,
        a.ATCLevel2Name,
        d.ATCLevel3Code,
        a.ATCLevel3Name,
        d.ATCLevel4Code,
        a.ATCLevel4Name,
        d.ATCLevel5Code,
        a.ATCLevel5Name
    FROM
    transactions t
    LEFT JOIN drug_lookUp d ON t.Drug_Code = d.MasterProductCode
    LEFT JOIN patients p ON t.Patient_ID = p.Patient_ID
    LEFT JOIN stores s ON t.Store_ID = s.Store_ID
    LEFT JOIN atc_lookup a ON d.ATCLevel5Code = a.ATCLevel5Code
    WHERE t.Patient_ID BETWEEN ${start} AND ${end}
    AND Prescription_Week < '2016-01-01'
    LIMIT 50000;" | while read -r line
    do
      patientId=`echo "$line" | cut -f1 | tr '[:upper:]' '[:lower:]'`
      gender=`echo "$line" | cut -f2`
      birthYear=`echo "$line" | cut -f3 | tr '[:upper:]' '[:lower:]'`
      patientPostCode=`echo "$line" | cut -f4 | tr '[:upper:]' '[:lower:]'`
      storeId=`echo "$line" | cut -f5`
      storeStateCode=`echo "$line" | cut -f6`
      storePostCode=`echo "$line" | cut -f7`
      prescriberId=`echo "$line" | cut -f8`
      drugId=`echo "$line" | cut -f9`
      drugCode=`echo "$line" | cut -f10`
      sourceSystemCode=`echo "$line" | cut -f11`
      prescriptionWeek=`echo "$line" | cut -f12`
      prescriptionWeekTS=`echo $(($(date -d"${prescriptionWeek}" +%s%3N)*1000000000))`
      dispenseWeek=`echo "$line" | cut -f13`
      dispenseWeekTS=`echo $(($(date -d"${dispenseWeek}" +%s%3N)*1000000000))`
      NHSCode=`echo "$line" | cut -f14`
      isDeferredScript=`echo "$line" | cut -f15`
      scriptQty=`echo "$line" | cut -f16`
      patientPriceAmount=`echo "$line" | cut -f17`
      chemistListPrice=`echo "$line" | cut -f38`
      wholesalePriceAmount=`echo "$line" | cut -f18`
      governmentReclaimAmount=`echo "$line" | cut -f19`
      repeatsTotalQty=`echo "$line" | cut -f20`
      dispensedQty=`echo "$line" | cut -f21`
      repeatsLeftQty=`echo "$line" | cut -f22`
      maxDispenseQty=`echo "$line" | cut -f23`
      [ -z "$maxDispenseQty" ] && maxDispenseQty=`echo "null"`
      streamlinedApprovalCode=`echo "$line" | cut -f24 | tr -d '\r\n'`
      [ -z "$streamlinedApprovalCode" ] && streamlinedApprovalCode=`echo "null"`
      drugMasterProductId=`echo "$line" | cut -f25`
      masterProductFullName=`echo "$line" | cut -f26`
      drugBrandName=`echo "$line" | cut -f27`
      drugFormCode=`echo "$line" | cut -f28`
      drugStrengthCode=`echo "$line" | cut -f29`
      drugPackSize=`echo "$line" | cut -f30`
      genericIngredientName=`echo "$line" | cut -f31`
      ethicalCategoryName=`echo "$line" | cut -f33`
      ethicalSubCategoryName=`echo "$line" | cut -f32`
      manufacturerCode=`echo "$line" | cut -f34`
      manufacturerName=`echo "$line" | cut -f35`
      manufacturerGroupId=`echo "$line" | cut -f36`
      manufacturerGroupCode=`echo "$line" | cut -f37`
      ATCLevel1Code=`echo "$line" | cut -f39`
      ATCLevel1Name=`echo "$line" | cut -f40`
      ATCLevel2Code=`echo "$line" | cut -f41`
      ATCLevel2Name=`echo "$line" | cut -f42`
      ATCLevel3Code=`echo "$line" | cut -f43`
      ATCLevel3Name=`echo "$line" | cut -f44`
      ATCLevel4Code=`echo "$line" | cut -f45`
      ATCLevel4Name=`echo "$line" | cut -f46`
      ATCLevel5Code=`echo "$line" | cut -f47`
      ATCLevel5Name=`echo "$line" | cut -f48`

      patientLocation=`[[ -f "./postcode/${patientPostCode}.json" ]] && (cat "./postcode/${patientPostCode}.json") || echo "null"`
      storeLocation=`[[ -f "./postcode/${storePostCode}.json" ]] && (cat "./postcode/${storePostCode}.json") || echo "null"`
      json="{
      \"patient\": {
        \"patientId\": ${patientId},
        \"gender\": \"${gender}\",
        \"birthYear\": ${birthYear},
        \"postCode\": ${patientPostCode},
        \"coordinates\": ${patientLocation}
      },
      \"store\": {
        \"storeId\": ${storeId},
        \"stateCode\": \"${storeStateCode}\",
        \"postCode\": ${storePostCode},
        \"coordinates\": ${storeLocation}
      },
      \"prescriberId\": \"${prescriberId}\",
      \"drugId\": ${drugId},
      \"drugCode\": \"${drugCode}\",
      \"sourceSystemCode\": \"${sourceSystemCode}\",
      \"prescriptionWeek\": \"${prescriptionWeek}\",
      \"dispenseWeek\": \"${dispenseWeek}\",
      \"NHSCode\": \"${NHSCode}\",
      \"isDeferredScript\": ${isDeferredScript},
      \"scriptQty\": ${scriptQty},
      \"patientPrice\": ${patientPriceAmount},
      \"chemistListPrice\": ${chemistListPrice},
      \"wholesalePrice\": ${wholesalePriceAmount},
      \"governmentReclaimAmount\": ${governmentReclaimAmount},
      \"repeatsTotal\": ${repeatsTotalQty},
      \"dispensed\": ${dispensedQty},
      \"maxDispense\": ${maxDispenseQty},
      \"repeatsLeft\": ${repeatsLeftQty},
      \"streamlinedApprovalCode\": ${streamlinedApprovalCode},
      \"drug\": {
          \"masterProductId\": ${drugMasterProductId},
          \"masterProductFullName\": \"${masterProductFullName}\",
          \"brand\": \"${drugBrandName}\",
          \"formCode\": \"${drugFormCode}\",
          \"strengthCode\": \"${drugStrengthCode}\",
          \"packSize\": \"${drugPackSize}\",
          \"genericIngredient\": \"${genericIngredientName}\",
          \"ethicalCategory\": \"${ethicalCategoryName}\",
          \"ethicalSubCategory\": \"${ethicalSubCategoryName}\",
          \"manufacturer\": {
            \"code\": \"${manufacturerCode}\",
            \"name\": \"${manufacturerName}\",
            \"groupId\": \"${manufacturerGroupId}\",
            \"groupCode\": \"${manufacturerGroupCode}\"
          }
      },
      \"ATCLevel1Code\": \"${ATCLevel1Code}\",
      \"ATCLevel1Name\": \"${ATCLevel1Name}\",
      \"ATCLevel2Code\": \"${ATCLevel2Code}\",
      \"ATCLevel2Name\": \"${ATCLevel2Name}\",
      \"ATCLevel3Code\": \"${ATCLevel3Code}\",
      \"ATCLevel3Name\": \"${ATCLevel3Name}\",
      \"ATCLevel4Code\": \"${ATCLevel4Code}\",
      \"ATCLevel4Name\": \"${ATCLevel4Name}\",
      \"ATCLevel5Code\": \"${ATCLevel5Code}\",
      \"ATCLevel5Name\": \"${ATCLevel5Name}\"
    }"
    json=`echo "${json}" | tr -d '\r\n' | tr -s ' '`
    es_response=`curl -s -XPOST "${es_host}/${es_index}/${es_type}/?pretty" -H 'Content-Type: application/json' -d "${json}"`
    failed=`echo "${es_response}" | jq -r "._shards.failed"`
    if [ "${failed}" -eq "1" ]; then
        echo "${es_response}," >> ./errors.json
    fi

    start=`expr $end + 1`
    end=`expr $end + $step`
    document=`expr $document + 1`
    done
    echo "Stored: ${document}"
done
echo "]" >> ./errors.json
echo "Done: ${document}"
