

DECLARE 
   c ticket.cost%type; 
BEGIN 
   c := total_passenger_in_route('dha-khu'); 
   dbms_output.put_line('Total Sell in this route =' || c); 
END; 
/

set serveroutput on;
BEGIN 
    
    Number_of_passenger_in_bus ('dha-khu');
END; 
/

select * from bus_details;

--insert into ticket values(1,1,4,null);
select * from passenger;
--view query
SELECT * FROM Available_Seats;







CREATE VIEW Available_Seats AS
SELECT Bus_id, ticket_price,available_seat
FROM bus_details
WHERE ticket_price > (SELECT AVG(ticket_price) FROM bus_details);

SELECT * FROM Available_Seats;

delete from ticket where bus_id=1;
select * from ticket;
select * from bus_details;

insert into ticket values(1,1,4,null);
update ticket
set quantity=3 
where bus_id=1;
insert into ticket values(2,7,6,null);
