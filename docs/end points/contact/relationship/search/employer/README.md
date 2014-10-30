# Employer search


This a dhtmlx combo focused end point

    GET    /contact/relationship/search/employer.xml

This is to be consumed by a DHTMLX combo only. Filtering need to be enabled.

https://perltest.myadoptionportal.com/contact/relationship/search/employer.xml?pos=0&mask=cha

https://perltest.myadoptionportal.com/contact/dhtmlx/combo/feed.xml?pos=20&mask=cha
pagination implemented on API layer, then it will have bad performance if compared with pagination on SP layer

Client side example:

    combo = new dhtmlXCombo("combo", "combo", 200);
    var combo_url = CAIRS.MAP.API.getMappedURL({
        resource: "/contact/relationship/search/employer",
        responseType: "xml",
        params : "EmployerConnId=0000"
    });
    combo.enableFilteringMode(true, combo_url, true, true);

this end point receives only two parameters:

    pos = for pagination support. automatically appended when using dhtmlx combo
    mask = string to search for. automatically appended when using dhtmlx combo

then you don't need to manually pass any parameter