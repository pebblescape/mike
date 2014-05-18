integration("Static");

test("Faq", function() {
  expect(1);
  visit("/").then(function() {
    ok(exists("h1"), "The content is present");
  });
});