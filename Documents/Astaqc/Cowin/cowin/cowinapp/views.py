from django.shortcuts import render
import requests

from django.http import HttpResponse
from django.shortcuts import render
# Create your views here.



def generateOTP(request):
        generateOTPurl = "https://cdn-api.co-vin.in/api/v2/auth/public/generateOTP"
        mobileNumber = request.POST.get("phoneNumber")
        data = {"mobile": mobileNumber}
        txnID = requests.post(generateOTPurl, json={"mobile":mobileNumber})
        return render(request, "result.html", {'result': txnID})

def validateOTP(request,response):
    validateOTPurl = "https://cdn-api.co-vin.in/api/v2/auth/public/confirmOTP"
    otp  = request.POST.get("otp")
    data = {
        "otp":otp,
        "txnId":response["txnId"]
    }
    token = request.post(validateOTPurl,json=data)
    return render(request,"success.html")



