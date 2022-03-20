-- Deliverable 1 - Query 1

select e.emp_no , e.first_name , e.last_name , t.title , t.from_date , t.to_date
into retirement_titles
from employees as e
join titles as t on e.emp_no = t.emp_no
where birth_date between '1952-01-01' and '1955-12-31'
order by e.emp_no;

-- End of query

-- Deliverable 1 - Query 2

SELECT DISTINCT ON (emp_no) emp_no , first_name ,last_name , title
INTO unique_titles
FROM retirement_titles
WHERE to_date = '9999-01-01'
ORDER BY emp_no asc , to_date DESC;

-- End of query

-- Deliverable 1 - Query 3

select count(title) , title from unique_titles
into retiring_titles
group by title
order by count(title) desc;

-- End of query

-- Deliverable 2 - Query 1

select e.emp_no , e.first_name , e.last_name , e.birth_date , d.from_date , d.to_date , t.title
into mentorship_eligibility
from employees as e
join dept_emp as d on e.emp_no = d.emp_no
join titles as t on e.emp_no = t.emp_no and d.to_date = t.to_date
where e.birth_date between '1965-01-01' and '1965-12-31'
and d.to_date = '9999-01-01'
order by e.emp_no;

-- End of query

-- Deliverable 3 - Additional queries

-- Create a summary table of number of employees by department by title

select de.dept_no , dp.dept_name , dt.title , count(*) "emp_count" , 0 "Ret_count"
into summary_by_dept_title
from dept_emp as de
join departments as dp on de.dept_no = dp.dept_no
join titles as dt on de.emp_no = dt.emp_no and de.to_date = dt.to_date
where de.to_date = '9999-01-01'
group by de.dept_no , dp.dept_name , dt.title;

-- Create a summary table of retirees by department by title

select de.dept_no , dp.dept_name , rt.title , count(rt.emp_no) 
into summary_ret_by_dept_title
from retirement_titles as rt
join dept_emp as de on rt.emp_no = de.emp_no and rt.to_date = de.to_date
join departments as dp on de.dept_no = dp.dept_no
where rt.to_date = '9999-01-01'
group by de.dept_no , dp.dept_name , rt.title
order by de.dept_no;

-- Join both the above table and display department number , department title , no of employees , no retiring and calculate percentage impact

select sd.dept_no , sd.dept_name , sd.title , sd.emp_count "No. Employees",
       COALESCE(rt.count,0) "No. Retiring", ROUND(((COALESCE(rt.count,0) / sd.emp_count::float)*100)) "% Impact"
from summary_by_dept_title as sd 
left join summary_ret_by_dept_title as rt on sd.dept_no = rt.dept_no and sd.dept_name = rt.dept_name and sd.title = rt.title
order by sd.dept_no;

-- Join both tables and display department number , department name , total employees by department , total retirees by departmnet and calculate % impact

select sd.dept_no , sd.dept_name ,  sum(sd.emp_count) "No. Employees" , sum(rt.count),
	   ROUND(((sum(COALESCE(rt.count,0)) / sum(sd.emp_count)::float)*100)) "% Impact"
from summary_by_dept_title as sd 
left join summary_ret_by_dept_title as rt on sd.dept_no = rt.dept_no and sd.dept_name = rt.dept_name and sd.title = rt.title
group by sd.dept_no , sd.dept_name
order by sd.dept_no;
-- End of query