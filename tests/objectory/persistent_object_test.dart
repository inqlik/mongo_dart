#library("PersistenObjectTests");
#import("../../lib/objectory/ObjectoryLib_vm.dart");
#import("../../lib/bson/bson.dart");
#import('../../third_party/unittest/unittest.dart');
#import("domain_model.dart");
testAuthorCreation(){
  Author author = new Author();
  author.name = 'vadim';
  author.age = 99;
  author.email = 'sdf';
  expect(author.map.getKeys()[0]).equals("_id");
  expect(author.map.getKeys()[1]).equals("name");
  expect(author.map.getKeys()[2]).equals("age");
  expect(author.map.getKeys().last()).equals("email");
  expect(author.map.getKeys().length).equals(4);
  expect(author.name).equals('VADIM'); // converted to uppercase by custom  setter;
}

testSetDirty(){
  Author author = new Author();
  author.name = "Vadim";
  expect(author.dirtyFields.length).equals(1);
  expect(author.isDirty()).isTrue();  
}
testCompoundObject(){
  Person person = new Person();  
  person.address.cityName = 'Tyumen';
  person.address.streetName = 'Elm';  
  person.firstName = 'Dick';  
  Map map = person.map;
  expect(map["address"]["streetName"]).equals("Elm");
  expect(person.address.parent).equals(person);
  expect(person.address.pathToMe).equals("address");
  expect(person.isDirty()).isTrue();
  expect(person.address.isDirty()).isTrue();
}
testFailOnSettingUnsavedLinkObject(){
  Person son = new Person();  
  Person father = new Person();  
  ;
  Expect.throws(()=>son.father = father,reason:"Link object must be saved (have ObjectId)");
}  
testFailOnAbsentProperty(){
  Author author = new Author();
  Expect.throws(()=>author.sdfsdfsdfgdfgdf,reason:"Must fail on missing property getter");
}
testNewInstanceMethod(){
  Author author = objectory.newInstance('Author');
  expect(author is Author).isTrue();       
}
testMap2ObjectMethod() {
  Map map = {
    "name": "Vadim",
    "age": 300,
    "email": "nobody@know.it"};
  Author author = objectory.map2Object("Author",map);
  //Not converted to upperCase because setter has not been invoked
  expect(author.name).equals("Vadim"); 
  expect(author.age).equals(300);
  expect(author.email).equals("nobody@know.it");
  map = {
    "streetName": "333",
    "cityName": "44444"
      };
  Address address = objectory.map2Object("Address",map);  
  expect(address.cityName).equals("44444");
}
testObjectWithListOfInternalObjects2Map() {
  var customer = new Customer();
  customer.name = "Tequila corporation";
  var address = new Address();
  address.cityName = "Mexico";
  customer.addresses.add(address);
  address = new Address();
  address.cityName = "Moscow";
  customer.addresses.add(address);
  var map = customer.map;
  expect(map["name"]).equals("Tequila corporation");  
  expect(map["addresses"].length).equals(2);
  expect(map["addresses"][0]["cityName"]).equals("Mexico");
  expect(map["addresses"][1]["cityName"]).equals("Moscow");
}
testMap2ObjectWithListOfInternalObjects() {
  var map = {"_id": null, "name": "Tequila corporation", "addresses": [{"cityName": "Mexico"}, {"cityName": "Moscow"}]};
  Customer customer = objectory.map2Object(CUSTOMER, map);
  expect(customer.name).equals("Tequila corporation");
  expect(customer.addresses.length).equals(2);
  expect(customer.addresses[1].cityName).equals("Moscow");
  expect(customer.addresses[0].cityName).equals("Mexico");
}

main(){
  registerClasses();  
  group("PersistenObjectTests", ()  {
    test("testAuthorCreation",testAuthorCreation);
    test("testSetDirty",testSetDirty);
    test("testCompoundObject",testCompoundObject);
    test("testFailOnAbsentProperty",testFailOnAbsentProperty);
    test("testFailOnSettingUnsavedLinkObject",testFailOnSettingUnsavedLinkObject);
    test("testMap2ObjectMethod",testMap2ObjectMethod);
    test("testNewInstanceMethod",testNewInstanceMethod);
    test("testObjectWithListOfInternalObjects2Map",testObjectWithListOfInternalObjects2Map);
    test("testMap2ObjectWithListOfInternalObjects",testMap2ObjectWithListOfInternalObjects);        
  });
}