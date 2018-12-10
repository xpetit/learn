package main

import (
	"bytes"
	"fmt"
	"reflect"
	"unsafe"
)

func assert(b bool) {
	if !b {
		panic(b)
	}
}

func main() {
	_a, _, _, _, _, _b :=
		(` `),
		(" "),
		(' '),
		` `,
		" ",
		' '

	_ = struct {
		string "_:\"_\"" // tagged
		rune   `_:"_"`   // tagged
	}{
		_a,
		_b,
	}

	_ = [][0][]****[]**********[][][][][][]****struct{}{}    // empty slice
	_ = [][0][]****[]**********[][][][][][]****struct{}(nil) // nil slice

	type (
		_  int
		_1 string
		_2 = string
		_3 = _1
		_4 _1
	)
	assert(_4(_3(_2(_1("hi")))) == "hi" == true == true == true == true)
	typeof := reflect.TypeOf
	assert(typeof(_1("")) != typeof(_2("")))
	assert(typeof(_1("")) == typeof(_3("")))
	assert(typeof(_2("")) == typeof(""))

	// "either 32 or 64 bits"
	assert(unsafe.Sizeof(int(0)) == 8)

	// "an unsigned integer large enough to store the uninterpreted bits of a pointer value"
	assert(unsafe.Sizeof(uintptr(0)) == 8)

	assert([...]int{1, 2, 3} == [3]int{1, 2, 3}) // array comparison
	assert([]string(nil) == nil)                 // slice comparison (allowed to nil value)
	assert(0. == .0)                             // 0.0
	assert(0. == 0)                              // 0.0
	assert(-+-+-+-+-+-+-+-+-+-42.000 == 42)
	assert(string([]rune{'a', 2: 'c'}) == "a\x00c")
	assert(string([]rune{'a', 2: 'c'}) == "a"+string(0)+"c")
	assert([]rune("a€"[1:])[0] == '€') // "a€" -> "€" -> []rune{'€'} -> '€' (rune)
	assert("a€"[:1][0] == 'a')         // "a€" -> "a" -> 'a' (byte)
	assert("a€"[:1] == "a")            // string comparison

	six := func() func() func() func() func() func() int {
		return func() func() func() func() func() int {
			return func() func() func() func() int {
				return func() func() func() int {
					return func() func() int {
						return func() int {
							return 6
						}
					}
				}
			}
		}
	}()()()()()()
	assert(six == 6)

	goto next
next:
	fmt.Println()

	// If the capacity of s is not large enough to fit the additional values, append allocates a new
	// sufficiently large underlying array that fits both the existing slice elements and the additional values.
	// Otherwise, append re-uses the underlying array.
	a := []byte{1, 2, 3, 4}   // len == 4, cap == 4
	b := a[:3]                // len == 3, cap == 4
	c := append(b, 4)         // len == 4, cap == 4
	d := append(b, 5)         // len == 4, cap == 4
	assert(bytes.Equal(c, d)) // [1, 2, 3, 5]
}
