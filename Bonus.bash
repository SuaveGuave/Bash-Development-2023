#!/bin/bash

#this program asks the user for a location to store their data, then asks for the number of salespersons they are storing data for, the month they are storing data for,
#the sales data for each person, and upon finishing, saves all this information to their file in their chosen directory, containing the saleperson data sorted by name,
#and by salary.

#NOTE - this script assumes that it will have read/write access to whatever directory you choose to save your text file in. You must input a linux filepath,
#meaning that copying and pasting a windows filepath will result in failure.

validate_positive_number() {
    local input=$1
    local regex='^[0-9]+(\.[0-9]+)?$'
    if [[ $input =~ $regex ]]; then
        return 0
    else
        return 1
    fi
}
#data validation, makes sure the user has inputted a positive number and no letters or symbols.

calculate_bonus() {
    sales=$1
    bonus=0
    if [ $(echo "$sales >= 650000" | bc) = 1 ]; then
        bonus=$(echo "30000 * 12" | bc)
    elif [ $(echo "$sales >= 500000" | bc) = 1 ]; then
        bonus=$(echo "25000 * 12" | bc)
    elif [ $(echo "$sales >= 400000" | bc) = 1 ]; then
        bonus=$(echo "20000 * 12" | bc)
    elif [ $(echo "$sales >= 300000" | bc) = 1 ]; then
        bonus=$(echo "15000 * 12" | bc)
    elif [ $(echo "$sales >= 200000" | bc) = 1 ]; then
        bonus=$(echo "10000 * 12" | bc)
    fi
    echo $bonus
}
#function to calculate bonus based on sales

calculate_tax() {
    salary=$1
    tax=0
    if [ $(echo "$salary > 50000" | bc) = 1 ]; then
        excess=$(echo "$salary - 50000" | bc)
        tax=$(echo "$excess * 40 / 100" | bc)
        tax=$(echo "$tax + 7500" | bc)  #basic tax for first 50000
    elif [ $(echo "$salary > 12500" | bc) = 1 ]; then
        excess=$(echo "$salary - 12500" | bc)
        tax=$(echo "$excess * 20 / 100" | bc)
    fi
    echo $tax
}
#function to calculate tax

bubble_sort_by_name() {
    n=$1
    for ((i = 0; i < n-1; i++)); do
        for ((j = 0; j < n-i-1; j++)); do
            k=$(( j + 1 ))
            if [[ "${months[j]} ${salespersons[j]}" > "${months[k]} ${salespersons[k]}" ]]; then
                temp=${salespersons[j]}
                salespersons[j]=${salespersons[k]}
                salespersons[k]=$temp
                
                temp=${salary[j]}
                salary[j]=${salary[k]}
                salary[k]=$temp
                
                temp=${months[j]}
                months[j]=${months[k]}
                months[k]=$temp
            fi
        done
    done
}
#function to bubble sort salespersons based on name alphabetically

bubble_sort_by_salary() {
    n=$1
    for ((i = 0; i < n-1; i++)); do
        for ((j = 0; j < n-i-1; j++)); do
            k=$(( j + 1 ))
            if [ -z "${salary[j]}" ] || [ -z "${salary[k]}" ]; then
                echo "DEBUG: Empty or invalid salary value detected"
                continue
            fi
            if (( ${salary[j]} < ${salary[k]} )); then
                temp=${salary[j]}
                salary[j]=${salary[k]}
                salary[k]=$temp
                
                temp=${salespersons[j]}
                salespersons[j]=${salespersons[k]}
                salespersons[k]=$temp
                
                temp=${months[j]}
                months[j]=${months[k]}
                months[k]=$temp
            fi
        done
    done
}
#function to bubble sort salespersons based on salary

echo "Enter directory to store data:"
read directory

echo "Enter file name to store data:"
read filename
#asks for file path and name to store data

directory="${directory//\\/\/}"
directory="${directory%/}"
#ensures proper formatting of the directory path by replacing backslashes with forward slashes and removing trailing slashes if they exist

output_file="$directory/$filename.txt"

touch "$output_file" || { echo "Error creating file"; exit 1; }
#create a new text file for storing data

echo "Enter number of salespersons (between 3 and 20):"
read num_salespersons

if (( num_salespersons < 3 || num_salespersons > 20 )); then
    echo "Number of salespersons should be between 3 and 20."
    exit 1
fi

#input data for each salesperson and store directly into the text file
echo "---------------------------------------------------" >> "$output_file"
echo "Salespersons data:" >> "$output_file"
for ((i = 0; i < num_salespersons; i++)); do
    echo "Enter details for salesperson $((i+1)):"

    #data validation to make sure the user inputted an actual month
    while true; do
        echo "Enter the month (e.g., January, February, etc.):"
        read month
        month_lower=$(echo "$month" | tr '[:upper:]' '[:lower:]')

        case $month_lower in
            january|february|march|april|may|june|july|august|september|october|november|december)
                #valid month
                break
                ;;
            *)
                #invalid month
                echo "Not a valid month. Please input a valid month."
                ;;
        esac
    done

    echo "Enter name:"
    read name
    echo "Name: $name" >> "$output_file"
    echo "Month: $month" >> "$output_file"

    while true; do
    echo "Enter total sales for A Class:"
    read sales_a
    if validate_positive_number "$sales_a"; then
        break
    else
        echo "Invalid input. Please enter a positive number (can include decimals)."
    fi
    done
    
    while true; do
    echo "Enter total sales for B Class:"
    read sales_b
    if validate_positive_number "$sales_b"; then
        break
    else
        echo "Invalid input. Please enter a positive number (can include decimals)."
    fi
    done

    while true; do
    echo "Enter total sales for C Class:"
    read sales_c
    if validate_positive_number "$sales_c"; then
        break
    else
        echo "Invalid input. Please enter a positive number (can include decimals)."
    fi
    done

    while true; do
    echo "Enter total sales for E Class:"
    read sales_e
    if validate_positive_number "$sales_e"; then
        break
    else
        echo "Invalid input. Please enter a positive number (can include decimals)."
    fi
    done

    while true; do
    echo "Enter total sales for AMG C65:"
    read sales_amg
    if validate_positive_number "$sales_amg"; then
        break
    else
        echo "Invalid input. Please enter a positive number (can include decimals)."
    fi
    done
    #data input for each salesperson and vehicle class

    total_sales=$(echo "$sales_a + $sales_b + $sales_c + $sales_e + $sales_amg" | bc)

    bonus=$(calculate_bonus $total_sales)
    total_salary=$(echo "24000 + $bonus" | bc)

    tax=$(calculate_tax $total_salary)
    net_salary=$(echo "$total_salary - $tax" | bc)

    salespersons[$i]=$name
    salary[$i]=$net_salary
    months[$i]=$month

    echo "Net Salary: $net_salary" >> "$output_file"
    echo "" >> "$output_file"
    #runs all necessary functions to calculate total sales, taxes, and bonuses, then stores them in arrays to be sorted.
done

echo "---------------------------------------------------" >> "$output_file"
echo "" >> "$output_file"

bubble_sort_by_name $num_salespersons
#bubble sort salespersons based on name

echo "Salespersons sorted by name:" >> "$output_file"
for ((i = 0; i < num_salespersons; i++)); do
    echo "Name: ${salespersons[i]}, Month: ${months[i]}, Net Salary: ${salary[i]}" >> "$output_file"
done
#output results sorted by name

echo >> "$output_file"

bubble_sort_by_salary $num_salespersons
#bubble sort salespersons based on salary

echo "Salespersons sorted by salary:" >> "$output_file" 
for ((i = 0; i < num_salespersons; i++)); do
    echo "Name: ${salespersons[i]}, Month: ${months[i]}, Net Salary: ${salary[i]}" >> "$output_file"
done
#output results sorted by salary

echo "---------------------------------------------------" >> "$output_file"

echo "Data saved successfully to $output_file, please take a look at the file for your results."

#directory im using on my laptop to save these files
#/mnt/c/Users/bart3/Documents/ubuntu files/sales_files
