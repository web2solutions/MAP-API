# dopayment End Point

Executes an authorize.net CC payments     

*dopayment*

	POST        /payments/authorizenet/dopayment.json

#### Mandatory parameters

	invoice_id 
	invoice_totalpay 
	pay_for_desc 
	customer_id 
	customer_email 
	billing_address1 
	billing_city 
	billing_country 
	billing_firstname 
	billing_lastname 
	billing_state 
	billing_zipcode 
	card_type 
	card_expirationdate 
	card_firstname 
	card_lastname 
	card_number 
	card_securitycode

	
#### Optional parameters
	
	billing_address2 
	billing_mobilenumber 
	billing_phonenumber 
	billing_companyname

	
### Restful client example

````javascript

	var params = "invoice_id=xxxx&invoice_totalpay=xxxx&pay_for_desc=xxxx&customer_id=xxxx&customer_email=xxxx&billing_address1=xxxx&billing_city=xxxx&billing_country=xxxx&billing_firstname=xxxx&billing_lastname=xxxx&billing_state=xxxx&billing_zipcode=xxxx&card_type=xxxx&card_expirationdate=xxxx&card_firstname=xxxx&card_lastname=xxxx&card_number=xxxx&card_securitycode=xxxx&billing_address2=xxxx&billing_mobilenumber=xxxx&billing_phonenumber=xxxx&billing_companyname=xxxx";

	CAIRS.MAP.API.post({
		resource: "/payments/authorizenet/dopayment",
		payload: params,
		onSuccess: function (request) {
			var json = JSON.parse(request.response);
			if (json.status == "success") {
	 
			}
			else {
				
			}
		},
		onFail: function (request) {
			var json = eval('(' + request.response + ')');
			
		}
	});
````
