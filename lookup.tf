/*
variable "v_azs"{
			default=["a=us-east-1a","b=us-east-1b","c=us_east-1c"]
			}
lookup(var.v_azs, "a"=./)

element  ----> list value ---- oka value pick chesthadi.
lookup  ------> map value ----oka value pick chesthadi.

string ---> {"sindhu","sunil"}
list----> [1,2,3,4,5,6,7,8,9,0]  
list(string)-----> ["sunil","sindhu"]
map ----> key=value -----> name=sindhu , hobby= swimming,

variable "a"{
	type		= string
	default 	= {"sunil","sindhu","amyjackson"}
}
variable "a"{
	type		= list
	default 	= [1,2,3,4,5]
}
variable "a"{
	type		= list(string)
	default 	= ["sunil","sindhu","amy","jackson"]
}
variable "aws"{
		name	= "sindhu"
		course	= "awsdevops"
		fees	= "50k"
		timing	= "7.30am"
}

ELEMENT will take both list and list of strings. map is neglected
LOOKUP  will take only Maps.


*/

variable "abc"{
	default		= [10,90,80]
}
output "out1" {
		value	= lookup(var.abc,0)
}


variable "abc"{
	default		= [10,90,80]
}
output "out2" {
		value	= element(var.abc,0)
}