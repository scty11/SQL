CREATE XML SCHEMA COLLECTION CategoriesSchema AS
N'<?xml version="1.0"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<xs:element name="Categories">
		<xs:complexType>
			<xs:sequence>
				<xs:element name="Category" maxOccurs="unbounded">
					<xs:complexType>
						<xs:sequence>
							<xs:element name="Name" type="xs:string"/>
						</xs:sequence>
						<xs:attribute name="ID" type="xs:string" use="required"/>
					</xs:complexType>
				</xs:element>
			</xs:sequence>
		</xs:complexType>
	</xs:element>
</xs:schema>'

--complextype indicates will have child elememts, put inside a sequence.
--
DECLARE @Categories xml-- (CategoriesSchema);

SET @Categories = 
'<Categories>
	<Category ID="4">
		<Name>Accessories</Name>
	</Category>
	<Category ID="3">
		<Name>Clothing</Name>
	</Category>
	<Category ID="2">
		<Name>Components</Name>
	</Category>
	<Category ID="1">
		<Name>Bikes</Name>
	</Category>
</Categories>'

DECLARE @documentHandle int;

EXEC sp_xml_preparedocument @documentHandle OUT, @Categories

SELECT *
--, second argument is the path, thrid is the display option, 1 for attributes, 2 for elements, 3 for both.
FROM OPENXML(@documentHandle, '/Categories/Category', 3)
WITH(
	Name varchar(50) 'Name',--will include the name values even if not select by the number above
	CategoryID	 int '@ID'--allows us to change the name to be output.
);
