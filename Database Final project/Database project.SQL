drop table ticket;
drop table route;
drop table station;
drop table bus_details;
drop table passenger;
create table passenger(
ps_id number,
name varchar(40),
ps_address varchar(40),
contact_no number unique,
primary key (ps_id)
);
create table bus_details(
bus_id number,
bus_name varchar(40),
ticket_price number,
total_capacity number,
available_seat number,
primary key(bus_id)
);
create table station(
Id number,
name varchar(40),
location varchar(40),
primary key (id)
);
create table route(
Id number,
bus_id number,
source_id number,
destination_id number,
/*time number(4,2),*/
route varchar(40),
primary key (id),
foreign key (source_id) references station(id) on delete cascade,
foreign key (source_id) references station(id) on delete cascade,
foreign key (bus_id) references bus_details(bus_id) on delete cascade
);
create table ticket(
ps_id number,
bus_id number,
quantity number,
cost number,
foreign key (bus_id) references bus_details(bus_id) on delete cascade,
foreign key (ps_id) references passenger(ps_id) on delete cascade
);
insert into station values(1 , 'gabtoli' ,'dhaka');
insert into station values(2 , 'zaflong' ,'sylhet');
insert into station values(3 , 'tigerpass' ,'chittagong');
insert into station values(4 , 'rangpur' ,'rangpur');
insert into station values(5 , 'fulbarigate' ,'khulna');
insert into station values(6 , 'dinajpur' ,'dinajpur');



insert into bus_details values(1 , 'shohag',550,45,45);
insert into bus_details values(2 , 'Dola',400,45,45);
insert into bus_details values(3 , 'Goldenline',500,45,45);
insert into bus_details values(4 , 'Falguni',600,45,45);
insert into bus_details values(5 , 'tungipara',550,45,45);
insert into bus_details values(6 , 'shohag',400,45,45);
insert into bus_details values(7 , 'Greenline',400,45,45);

insert into route values(1,1,1,5,'dha-khu');
insert into route values(11,7,1,5,'dha-khu');
insert into route values(2,1,5,1,'khu-dha');
insert into route values(3,3,1,2,'dha-syl');
insert into route values(4,3,2,1,'syl-dha');
insert into route values(5,2,1,3,'dha-chi');
insert into route values(6,2,3,1,'chi-dha');
insert into route values(7,4,1,3,'dha-din');
insert into route values(8,4,3,1,'din-dha');
insert into route values(9,5,1,4,'dha-rang');
insert into route values(10,5,4,1,'rang-dha');

--insert
CREATE OR REPLACE TRIGGER up_insert
  AFTER INSERT ON ticket
 FOR EACH ROW
BEGIN
  UPDATE bus_details
     SET available_seat = (:new.quantity-available_seat)*-1
   WHERE bus_id = :NEW.bus_id;
END;


--update
CREATE OR REPLACE TRIGGER up_update
  AFTER update ON ticket
 FOR EACH ROW
 declare
 a bus_details.available_seat%type;
 b bus_details.available_seat%type;
BEGIN
    select available_seat into b from bus_details where bus_id=:new.bus_id;
    a:=b+:old.quantity;
  UPDATE bus_details
     SET available_seat = (:new.quantity-a)*-1
   WHERE bus_id = :NEW.bus_id;
END;

--ticket delete
CREATE OR REPLACE TRIGGER up_delete
 after delete ON ticket
 FOR EACH ROW
 Declare
 a bus_details.total_capacity%type;
 b number;
 c BUS_DETAILS.AVAILABLE_SEAT%type;
BEGIN
   select available_seat into c from bus_details where bus_id=:old.bus_id;
   c:=c+:old.quantity;
  UPDATE bus_details
     SET available_seat = c
   WHERE bus_id = :old.bus_id;
END;


CREATE OR REPLACE TRIGGER update_cost
  before INSERT ON ticket
 FOR EACH ROW
 declare m bus_details.ticket_price%type;
BEGIN
 select ticket_price into m from bus_details where bus_id=:new.bus_id;
  :new.cost:= :new.quantity*m;
END;

CREATE OR REPLACE function total_sell(p_route in route.route%type)
return number is
   total number := 0;
   c_id route.bus_id%type;
   c_num ticket.quantity%type;
   cursor c_busid is
   select bus_id from route where route=p_route;
   
   cursor c_cost is
   select cost from ticket where bus_id=c_id;
   
   begin
     open c_busid;
     loop
     fetch c_busid into c_id;
     EXIT WHEN c_busid%notfound;
     open c_cost;
     loop
     fetch c_cost into c_num;
     EXIT WHEN c_cost%notfound;
     total:=total+c_num;
     end loop;
     close c_cost;
     end loop;
     close c_busid;
     return total;
   end;



CREATE OR REPLACE PROCEDURE Number_of_passenger_in_bus (r in route.route%type)
AS 
t  BUS_DETAILS.TOTAL_CAPACITY%type;
a BUS_DETAILS.AVAILABLE_SEAT%type;
b bus_details.bus_id%type;
c number :=0;
cursor c_busid is
   select bus_id from route where route=r;
BEGIN 
    open c_busid;
     loop
     fetch c_busid into b;
     EXIT WHEN c_busid%notfound;
    select total_capacity into t from bus_details where bus_id=b;
    select available_seat into a from bus_details where bus_id=b;
    c:=c+t-a;
   end loop;
     close c_busid;
     dbms_output.put_line('number of passenger on this route'||'_'||r ||'='|| c);
END; 
/

create or replace directory MYDIR as 'C:\Users\Somir\Desktop';
grant read,write on directory MYDIR to public;
declare
    f utl_file.file_type;
    line varchar(10000);
    id passenger.ps_id%type;
    name passenger.name%type;
    address PASSENGER.PS_ADDRESS%type;
    contact_no PASSENGER.CONTACT_NO%type;
    
begin
    f:= utl_file.fopen('MYDIR','data.csv','R');
    if utl_file.is_open(f) then
        utl_file.get_line(f,line,10000);
       loop 
    begin
    utl_file.get_line(f,line,10000);
    if line is null then exit;
    end if;
       id:=regexp_substr(line,'[^,]+',1,1);
       name:=regexp_substr(line,'[^,]+',1,2);
       address:=regexp_substr(line,'[^,]+',1,3);
       contact_no:=regexp_substr(line,'[^,]+',1,4);
       insert into passenger values(id,name,address,contact_no);
    commit;
    exception
    when no_data_found then exit;
    end;  
    end loop;  
   
    end if;
utl_file.fclose(f);
end;
/
--insert into ticket values(2,7,6,null);
--insert into ticket values(1,1,4,null);
--create or replace directory MYDIR as 'C:\Users\Somir\Desktop';
--grant read,write on directory MYDIR to public;
declare
   f utl_file.file_type;
   cursor c is select * from ticket;
   
 begin
 f:= utl_file.fopen('MYDIR','write.csv','W');
 utl_file.put(f,'PS_ID' || ',' || 'BUS_ID' || ',' || 'Quantity' || ',' || 'Cost');
    utl_file.new_line(f);
    for c_record in c
    loop
        utl_file.put(f,c_record.ps_id || ',' || c_record.BUS_ID|| ',' || c_record.quantity ||','|| c_record.cost);
        utl_file.new_line(f);
        end loop;
 utl_file.fclose(f);
 end;
 
--view creation
CREATE OR Replace VIEW Available_Seats AS
SELECT Bus_id, ticket_price,available_seat
FROM bus_details
WHERE ticket_price > (SELECT AVG(ticket_price) FROM bus_details);


--join
SELECT Bus_details.bus_name, BUS_DETAILS.TICKET_PRICE,BUS_DETAILS.AVAILABLE_SEAT,Route.route
FROM Bus_details
INNER JOIN route ON bus_details.bus_id = route.id;

commit;
