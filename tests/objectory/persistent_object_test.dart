#library("PersistenObjectTests");
#import("../../lib/objectory/objectory_vm.dart");
#import("../../lib/bson/bson.dart");
#import('../../third_party/unittest/unittest.dart');
#import("domain_model.dart");
testAuthorCreation(){
  var author = new Author();
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
  var author = new Author();
  author.name = "Vadim";
  expect(author.dirtyFields.length).equals(1);
  expect(author.isDirty()).isTrue();  
}
testCompoundObject(){
  var person = new Person();  
  person.address.cityName = 'Tyumen';
  person.address.streetName = 'Elm';  
  person.firstName = 'Dick';  
  Map map = person.map;
  expect(map["address"]["streetName"]).equals("Elm");
  expect(person.address.parent).equals(person);
  expect(person.address.pathToMe).equals("address");
  expect(person.isDirty()).isTrue();
//  expect(person.address.isDirty()).isTrue();
}
testFailOnSettingUnsavedLinkObject(){
  var son = new Person();  
  var father = new Person();  
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
  expect(map["addresses"][0] is! PersistentObject).isTrue();
  expect(map["addresses"][0]["cityName"]).equals("Mexico");
  expect(map["addresses"][1]["cityName"]).equals("Moscow");  
}
testMap2ObjectWithListOfInternalObjects() {
  var map = {"_id": null, "name": "Tequila corporation", "addresses": [{"cityName": "Mexico"}, {"cityName": "Moscow"}]};
  var customer = objectory.map2Object($Customer.className, map);
  expect(customer.name).equals("Tequila corporation");
  expect(customer.addresses.length).equals(2);
  expect(customer.addresses[1].cityName).equals("Moscow");
  expect(customer.addresses[0].cityName).equals("Mexico");
}
testObjectWithListtOfExternalRefs2Map() {
  Person father;
  Person son;
  Person daughter;
  Person sonFromObjectory;
  father = new Person();  
  father.firstName = 'Father';
  father.id = new ObjectId();
  father.map["_id"] = father.id;
  objectory.addToCache(father);
  son = new Person();  
  son.firstName = 'Son';
  son.father = father;
  son.id = new ObjectId();
  son.map["_id"] = son.id;
  objectory.addToCache(son);
  daughter = new Person();
  daughter.father = father;
  daughter.firstName = 'daughter';
  daughter.id = new ObjectId();
  daughter.map["_id"] = daughter.id;
  objectory.addToCache(daughter);
  father.children.add(son);  
  father.children.add(null);
  father.children[1] = daughter;
  expect(father.map["children"][0]).equals(son.id);
  expect(father.map["children"][1]).equals(daughter.id);
}
testMap2ObjectWithListtOfInternalObjectsWithExternalRefs() {
  User user = new User();
  user.login = 'testLogin';
  user.name = 'TestUser';  
  user.id = new ObjectId();
  user.map["_id"] = user.id;
  objectory.addToCache(user);
  Map articleMap = {"title": "test article", "body": "sasdfasdfasdf", 
                    "comments": [{"body": "Excellent", "user": user.id}]};               
  Article article = objectory.map2Object($Article.className,articleMap);
  expect(article.map["comments"][0]["user"]).equals(user.id);
  expect(article.comments[0].user).equals(user);
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
    test("testObjectWithListtOfExternalRefs2Map",testObjectWithListtOfExternalRefs2Map);
    test("testMap2ObjectWithListtOfInternalObjectsWithExternalRefs",testMap2ObjectWithListtOfInternalObjectsWithExternalRefs);    
  });
}