 ### Go Functions
 
 ```
 func printPrice(product string, price float64, taxRate float64) {
  ...
  ...
 }
 ```
 
 The function parameter type can be omitted when adjacent parameters have the same type
 ```
 func printPrice(product string, price, taxRate float64) {
  ...
  ...
 }
 ```
 
 One can omit the function parameter name as well.
 
 ```
 func printPrice(product string, price, _ float64) {
  ...
  ...
 }
 ```
 
 _ => 
 - underscore => blank identifier
 - indicates param is not used in the function
 - This can be useful when implementing the methods required by an interface 
 
 Variadic Parameters => function accepts variable number of arguments 
 
 W/o using Variadic Parameter, one can use slice as alternate solution
 
```
package main
import "fmt"

 func printSuppliers(product string, suppliers []string ) {
    for _, supplier := range suppliers {
        fmt.Println("Product:", product, "Supplier:", supplier)
    }
}

func main() {
    printSuppliers("Kayak", []string {"Acme Kayaks", "Bob's Boats", "Crazy Canoes"})
    printSuppliers("Lifejacket", []string {"Sail Safe Co"})
}

```

Issue is even for single param to pass, caller has to create a slice.
Solution => use Variadic Parameter

```
package main
import "fmt"
func printSuppliers(product string, suppliers ...string ) {
    for _, supplier := range suppliers {
        fmt.Println("Product:", product, "Supplier:", supplier)
    }
}
func main() {
    printSuppliers("Kayak", "Acme Kayaks", "Bob's Boats", "Crazy Canoes")
    printSuppliers("Lifejacket", "Sail Safe Co")
}
```

If no arguments passed for Variadic Parameter, then it is taken as nil.
lenght of Variadic Parameter is 0 if caller does not pass any arguments

```
package main
import "fmt"
func printSuppliers(product string, suppliers ...string ) {
    if (len(suppliers) == 0) {
        fmt.Println("Product:", product, "Supplier: (none)")
    } else {
        for _, supplier := range suppliers {
            fmt.Println("Product:", product, "Supplier:", supplier)
        }
    }
}
func main() {
    printSuppliers("Kayak", "Acme Kayaks", "Bob's Boats", "Crazy Canoes")
    printSuppliers("Lifejacket", "Sail Safe Co")
    printSuppliers("Soccer Ball")
}
```

Output

```
Product: Kayak Supplier: Acme Kayaks
Product: Kayak Supplier: Bob's Boats
Product: Kayak Supplier: Crazy Canoes
Product: Lifejacket Supplier: Sail Safe Co
Product: Soccer Ball Supplier: (none)
```

If caller has a slice to pass, then call the function with ellipsis

```
supplierNames := []string {"Acme Kayaks", "Bob's Boats", "Crazy Canoes"}
printSuppliers("Kayak", supplierNames...)
```

This technique avoids unpacking slice into individual values


#### Using Pointers as Function Parameters

```
func swap(first, second *int) {
 temp: = first
 first := second
 second := temp
}
```

#### Returning Multiple Function Results

```
package main

import "fmt"

func swap(f, s int) (int, int) {
	return s, f
}

func main() {
	v1, v2 := 10, 20
	v1, v2 = swap(v1, v2)
	fmt.Println("After swap ", v1, v2)
}

```

#### Naming the return result of a function

```
package main

import "fmt"

func swap(f, s int) (first, second int) {
	first = s
	second = f
	return
}

func main() {
	v1, v2 := 10, 20
	v1, v2 = swap(v1, v2)
	fmt.Println("After swap ", v1, v2)
}

```

#### Using blank identifier to discard the result

```
package main

import "fmt"

func someFunc(f, s int) (discard, accept int) {
	discard = f
	accept = s
	return
}

func main() {

	_, a := someFunc(20, 10)
	fmt.Println("a: ", a)
}

```

#### defer keyword
used to schedule function call before the current function return
e.g. close open files, netwrok connection
multiple defer calls can be used in same function

```
package main

import "fmt"

func testDefer() {
	fmt.Println("In testDefer")
	defer fmt.Println("First Defer")
	// some work....
	defer fmt.Println("second Defer")
}

func main() {
	fmt.Println("Hello")
	testDefer()
}
```

Output
```
Hello
In testDefer
second Defer
First Defer
```

### Function Types

This means functions have a data type
They can be assigned to a variable


```
package main

import "fmt"

func callMe() {
	fmt.Println("In callMe")
}

func callOther() {
	fmt.Println("In callOther")
}

func main() {
	fmt.Println("Hello")
	var fn func()
	fmt.Println("Function assigned:", fn == nil)
	fn = callMe
	fn()
	fn = callOther
	fn()
	fmt.Println("Function assigned:", fn == nil)
}

```
Go comparison operators cannot be used to compare functions
but they can be used to determine whether a function has been assigned to a variable

Functions can be passed as a paramater to the function and can return a value of type function as well

```
package main
import "fmt"
type calcFunc func(float64) float64
func calcWithTax(price float64) float64 {
    return price + (price * 0.2)
}
func calcWithoutTax(price float64) float64 {
    return price
}
func printPrice(product string, price float64, calculator calcFunc) {
    fmt.Println("Product:", product, "Price:", calculator(price))
}
func selectCalculator(price float64) calcFunc {
    if (price > 100) {
        return calcWithTax
    }
    return calcWithoutTax
}
func main() {
    products := map[string]float64 {
        "Kayak" : 275,
        "Lifejacket": 48.95,
    }
    for product, price := range products {
        printPrice(product, price, selectCalculator(price))
    }
}
```

Type aliasing => can assign a name to a function signature

```
type calcFunc func(float64) float64
```

### Literal Function

```
package main

import "fmt"

func main() {
	sum := func(a, b int) int {
		return a + b
	}
	fmt.Println("sum: ", sum(10, 20))
}

```

Go does not support arrow function syntax  
Functions don’t have to be assigned to variables and can be used just like any other literal value  
Literal functions can also be used as arguments to other functions  

### Anonymous Functions

```
package main

import (
	"fmt"
)

func give_me_a_func() func(string) {
	return func(message string) {
		fmt.Println(message)
	}
}

func main() {
	print := give_me_a_func()
	print("Hi")

}

```

### Function Closure

Clousre
- Literal functions can refer a variable from the surrounding code
- is an inner function that has access to the variables in the scope in which it was created. 
- This applies even when the outer function finishes execution and the scope gets destroyed.


```
package main

import "fmt"

func inc() func() int {
	i := 10
	return func() int {
		i++
		return i
	}
}

func main() {
	fmt.Println("Hello")
	next := inc()
	fmt.Println(next()) // prints 11
	fmt.Println(next()) // prints 12
	fmt.Println(next()) // prints 13
}

```

### Go Struct

#### Anonymous Struct Types

```
package main

import "fmt"

func writeName(val struct {
	name, category string
	price          float64
}) {
	fmt.Println("Name:", val.name)
}

func main() {
	type Product struct {
		name, category string
		price          float64
	}

	type Item struct {
		name     string
		category string
		price    float64
	}
	prod := Product{name: "Ball", category: "Cricket", price: 275.50}

	writeName(prod)
	item := Item{name: "Racket", category: "Tennis", price: 75000}
	writeName(item)
	writeName(Product(item)) // e.g of converting between struct types

	type OtherItem struct {
		n string
		c string
		p float64
	}
	// otheritem := OtherItem{n: "King", c: "Chess", p: 55}
	// writeName(otheritem) //  cannot use otheritem (variable of type OtherItem) as struct{name string; category string; price float64} value in argument to writeName
	// writeName(Product(otheritem)) // cannot convert otheritem (variable of type OtherItem) to type Product
}

```

Output

```
Name: Ball
Name: Racket
Name: Racket
```

### Embedded fields in struct

Only one embedded field can be defined bec field names must be unique

```
package main
import "fmt"
func main() {
    type Product struct {
        name, category string
        price float64
    }
    type StockLevel struct {
        Product
        Alternate Product	// assigning a name
        count int
    }
    stockItem := StockLevel {
        Product: Product { "Kayak", "Watersports", 275.00 },
        Alternate: Product{"Lifejacket", "Watersports", 48.95 },
        count: 100,
    }
    fmt.Println("Name:", stockItem.Product.name)
    fmt.Println("Alt Name:", stockItem.Alternate.name)
}
```

Go follows pointers to struct fields without needing an asterisk character, 

```
package main

import "fmt"

type Product struct {
	name, category string
	price          float64
}

func printProdName(p *Product) {
	fmt.Println("Name:", (*p).name)
	fmt.Println("Name:", p.name)

	fmt.Printf("DataTypes\np: %T\n*p: %T\n", p, *p)
}

func main() {
	racket := Product{
		name:     "Racket",
		category: "Tennis",
		price:    850,
	}
	printProdName(&racket)

	ball := &Product{
		name:     "Ball",
		category: "Cricket",
		price:    220.30,
	}

	printProdName(ball)

}

```

Output
```
Name: Racket
Name: Racket
DataTypes
p: *main.Product
*p: main.Product
Name: Ball
Name: Ball
DataTypes
p: *main.Product
*p: main.Product

```


### Construtor function

```
package main

import "fmt"

type Product struct {
	name, category string
	price          float64
}

func newProduct(name, category string, price float64) *Product {
	return &Product{name, category, price} // Returns the struct pointer
}

func newProduct1(name, category string, price float64) Product {
	return Product{name, category, price} // Return by value
}

func main() {
	productsArray := [2]Product{
		newProduct1("Kayak", "Watersports", 275),
		newProduct1("Hat", "Skiing", 42.50),
	}

	fmt.Printf("DataTypes: productsArray: %T\n", productsArray)

	productsPointrArray := [2]*Product{
		newProduct("Kayak", "Watersports", 275),
		newProduct("Hat", "Skiing", 42.50),
	}

	fmt.Printf("DataTypes: productsPointrArray: %T\n", productsPointrArray)

	for _, p := range productsPointrArray {
		fmt.Printf("DataTypes: p: %T *p: %T\n", p, *p)
		fmt.Println("Name:", p.name, "Category:", p.category, "Price", p.price)
	}
}

```

Output

```
DataTypes: productsArray: [2]main.Product
DataTypes: productsPointrArray: [2]*main.Product
DataTypes: p: *main.Product *p: main.Product
Name: Kayak Category: Watersports Price 275
DataTypes: p: *main.Product *p: main.Product
Name: Hat Category: Skiing Price 42.5
```


Go doesn’t have built-in support for performing a deep copy

```
package main
import "fmt"
type Product struct {
    name, category string
    price float64
    *Supplier
}
type Supplier struct {
    name, city string
}
func newProduct(name, category string, price float64, supplier *Supplier) *Product {
    return &Product{name, category, price -10, supplier}
}

func main() {
    acme := &Supplier { "Acme Co", "New York"}
    p1 := newProduct("Kayak", "Watersports", 275, acme)
    p2 := *p1
    p1.name = "Original Kayak"
    p1.Supplier.name = "BoatCo"
    for _, p := range []Product { *p1, p2 } {
        fmt.Println("Name:", p.name, "Supplier:",
            p.Supplier.name, p.Supplier.city)
    }
}
```

Output

```
Name: Original Kayak Supplier: BoatCo New York
Name: Kayak Supplier: BoatCo New York
```
