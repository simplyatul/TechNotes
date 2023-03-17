 Go Functions
 
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


