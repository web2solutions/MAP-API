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

	
#### Options parameters
	
	billing_address2 
	billing_mobilenumber 
	billing_phonenumber 
	billing_companyname

	
### Restful client example
	
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

