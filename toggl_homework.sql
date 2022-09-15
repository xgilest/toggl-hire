--sql souspicious candidates for job opening id = 99
select c1.* from candidates c1 where c1.applied = 99 and (
    (select count(*) from candidates c2 where sanitize_email2(c1.email) = sanitize_email2(c2.email)) > 1
OR (select count(*) from candidates c2 where c1.ip_address = c2.ip_address) > 1)
union
select c.*
from candidates c
         join test_takes tt on c.id = tt.candidate
where applied = 99 and (tt.submitted - tt.started < '3 minutes')
UNION
select c.*
from candidates c
    inner join test_takes on c.id = test_takes.candidate
    inner join awnsers a on test_takes.id = a.test_take
    inner join fraud_events fe on a.id = fe.awnser
where c.applied = 99
group by c.id
having count(fe.id) > 1;


-- sql retrive candidates from workspace with filters and pagination
select c.*, tt.score from candidates c
    inner join openings o on o.id = c.applied
    inner join test_takes tt on c.id = tt.candidate
where o.workspace = 14
    and o.id =36
    and tt.score > 80
    and c.id > 628939 -- last record id for pagination
order by c.id
limit 50; --page size;
