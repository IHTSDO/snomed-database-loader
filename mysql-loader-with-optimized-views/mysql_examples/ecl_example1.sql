​I have looked at your questions, and I hope that the following will clarify your questions:


1) It is uncommon that you specify the |is a| attribute for the purpose of creating a postcoordinated expression. You would specify the supertypes of a concept when you author a new concept, for example, if you were creating an extension concept. In your situation, where you want to represent the left and right tendon of forearm and hand respectively, I suggest that you simply do it as follows:

360496004 |Structure of tendon of forearm and/or hand (body structure)|: 272741003 |Laterality (attribute)|= 24028007 |Right (qualifier value)|
360496004 |Structure of tendon of forearm and/or hand (body structure)|: 272741003 |Laterality (attribute)|= 24028007 |Right (qualifier value)|
Note:
It is not correct to state that 360496004 |Structure of tendon of forearm and/or hand (body structure)|: 116680003 |Is a (attribute)|= 71685008 |Structure of common tendon (body structure)|, because when you look in the browser the concept 360496004 |Structure of tendon of forearm and/or hand| is NOT subsumed by |Structure of common tendon| 
You can confirm this using the following expression constraint: < 71685008 AND 360496004 - this query will return no results because there is no conjunction between < 71685008 and 360496004. Had 360496004 been a subtype of 71685008, then the concept 360496004 would have been returned. This is an easy way for you to check the subsumption relationship between two concepts using ECL.
Remember that when adding laterality to a body structure, you should confirm that the concept is a member of the 723264001 |Lateralizable body structure reference set (foundation metadata concept)| as this refset includes all concepts where you can apply a laterality
You can confirm that the concept in focus is included in the refset using this expression constraint: ^ 723264001 |Lateralizable body structure reference set| AND 360496004 - as you can see it is okay to apply laterality to this concept.
2 and 3) I am afraid I need some more detail to answer. First, can you explain to me what meaning you are trying to represent through this expression? I can't figure out what term or concept you would map to that expression... If you send me some detail, I will forward that to our Anatomy expert to have him help with the correct expression for that meaning. 

Furthermore, the expression you ask about is syntactically okay (you can test that here: apg.ihtsdotools.org). I.e. the syntax supports nested expressions like the expression you use for the attribute value (see the last example on this page: https://confluence.ihtsdotools.org/display/DOCECL/6.7+Nested+Expression+Constraints). When you look in the Editorial Guide or the MRCM refsets, you find that the range for the |Systemic part of| attribute is <<  123037004 |Body structure (body structure)|, and the reason why the self-built parser fails, is probably that the target, in this case, is not a precoordinated concept which is a subtype of |Body structure|, but the expression (71685008 |Structure of common tendon (body structure)|:272741003 |Laterality (attribute)|=7771000 |Left (qualifier value)|). This expression represents a body structure, and you can therefore argue that the expression conform to the concept model as well. However, as the concept model for anatomy is not yet applied to International content, I would recommend that you don't use the |Systemic part of| attribute for postcoordination - at least until we start to release content with these attributes, and the concept model for this hierarchy is more stable. It is perfectly fine to create expressions for lateralized body structures - but for more advanced body structures, you should rather request for content to be added as pre-coordinated concepts in the International Edition than creating the meanings yourself.
​
4) Wrt. parsers, and here I assume that you are looking for a parser, which also validates whether the expression conforms to the concept model - and not only the syntax... Then, I am afraid I am not aware of systems that allow you to construct and validate postcoordinated expressions. I agree, it would be a very useful system to have for implementers that support postcoordination.
​
5) With respect to the difference between stated and inferred view, you are correct:
Stated view:
This view shows the supertypes and defining relationships that are manually assigned by the author.
Inferred view:
The inferred view shows the classified definition of a concept, including the inferred supertypes and additional defining properties.
Different types of inferred views exist, which can be used for different purposes, and these different types of inferred views differ in terms of the amount of redundancy.
In the SNOMED International Browser, the Inferred view includes redundant defining properties, but it does not include redundant |is a| relationships.
​
