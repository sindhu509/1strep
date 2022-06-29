data "aws_availability_zones" "azs" {
}

variable "vpc_cidr" {
}
resource "aws_vpc" "vpc00" {
  cidr_block = var.vpc_cidr
  tags       = { Name = "vpc00" }
}
resource "aws_subnet" "subnets" {
  count             = length(data.aws_availability_zones.azs.names) * 2
  vpc_id            = aws_vpc.vpc00.id
  map_public_ip_on_launch = "true"
  cidr_block        = cidrsubnet("10.0.0.0/16", 8,count.index)
  availability_zone = element(data.aws_availability_zones.azs.names,count.index)
  tags = {
  Name= count.index<3?"pub-${count.index}":"priv-${count.index}"
  }
}

resource	"aws_internet_gateway"	"igw1"{
		vpc_id		= aws_vpc.vpc00.id
		tags	= {
			Name	= "igw-vpc00"
		}
}
resource 	"aws_route_table"	"pubrt"{
		vpc_id		= aws_vpc.vpc00.id
		route	{
				cidr_block		= "0.0.0.0/0"
				gateway_id		= aws_internet_gateway.igw1.id
		}
		tags = {
			Name = "pub-rt-vpc00"
		}
}
resource	"aws_route_table_association"	"pubrtass"{
		count			= length(data.aws_availability_zones.azs.names)
		subnet_id		= aws_subnet.subnets.*.id[count.index]
		route_table_id	= aws_route_table.pubrt.id
}

resource 	"aws_instance"	"i1"{
		#count			= length(data.aws_availability_zones.azs.names)
		subnet_id		= aws_subnet.subnets.*.id[0]
		ami 			= "ami-02f3416038bdb17fb"
		instance_type	= "t2.micro"
		key_name		= aws_key_pair.key1.key_name
		vpc_security_group_ids	= [aws_security_group.sg1.id]
		tags={
		Name	= "instance1"
		}
}

resource 	"aws_key_pair"	"key1"{
		key_name   = "key-1"
		public_key	= file("./instance1.pub")
}

resource  "aws_ebs_volume"	"volumes"{
		#count		= length(data.aws_availability_zones.azs.names)
		size		= 8
		type		= "gp2"
		availability_zone = aws_instance.i1.availability_zone
		tags= {
		Name 	= "instance1-vol2"
		}
}
resource  "aws_volume_attachment"	"volattach"{
		#count		= length(data.aws_availability_zones.azs.names)
		instance_id	= aws_instance.i1.id
		volume_id	= aws_ebs_volume.volumes.id
		device_name	= "/dev/sdf"
}

locals {
	inbound_ports = [80, 22]
	outbound_ports= [{
			port = 0
			protocol = -1
	}]
}
resource	"aws_security_group"	"sg1"{
		name				= "sg1"
		description			= "allow 22 and 80 ports"
		vpc_id				= aws_vpc.vpc00.id
		dynamic "ingress"{
				for_each		 = local.inbound_ports
				content{
					description      = "ports 22 and 80"
					from_port        = ingress.value
					to_port          = ingress.value
					protocol         = "tcp"
					cidr_blocks		 = ["0.0.0.0/0"]
		}
}
		dynamic "egress"{
				for_each		 = local.outbound_ports
				content{
					description      = "all traffic"
					from_port        = egress.value.port
					to_port          = egress.value.port
					protocol         = egress.value.protocol
					cidr_blocks		 = ["0.0.0.0/0"]
		}
}
}