database = firebase.firestore();

const cardsSegmentId = document.getElementById('cardsSegment');
const alertIconId = document.getElementById('alertIcon');
const alertMessageId = document.getElementById('alertMessage');
const alertHeaderId = document.getElementById('alertHeader');
const payLaterId = document.getElementById('payLater');
const payNowId = document.getElementById('payNow');

// to add input field value to firestore as an array
function onButtonClick(doc, name) {
    database.collection("subjectCards").doc(doc.id).update({
        studentName: firebase.firestore.FieldValue.arrayUnion(name),
    });
    alertIconId.className = "check green circle icon";
    alertMessageId.textContent = "Your name has been sent successfully :)";
    alertHeaderId.textContent = "ThankYou";
    payNowId.style.display = "initial"
    payLaterId.textContent = "Pay Later"
    payNowId.textContent = "Pay Now"
    $('.ui.basic.modal')
        .modal('show');
}

// alert function
function showAlert() {
    alertIconId.className = "close red icon";
    alertMessageId.textContent = "Please fill the input field  :(";
    alertHeaderId.textContent = "Error";
    payLaterId.textContent = "Done"
    payNowId.style.display = "none"
    $('.ui.basic.modal')
        .modal('show');
}

// JavaScript HTML DOM
function listCards(doc) {

    let card = document.createElement('div');
    card.className = "ui green segment item";
    card.setAttribute('data-id', doc.id);

        let header = document.createElement('h2');
        header.className = "header";
        header.style.textTransform = "uppercase";
        header.textContent = doc.data().subjectName;

        let price = document.createElement('h3');
        price.className = "description";
        price.textContent = "₹ " + doc.data().cost;

        let description = document.createElement('h4');
        description.className = "content";
        description.textContent = doc.data().description;

    let rightContent = document.createElement('div');
    rightContent.className = "right floated content";

        let input = document.createElement('div');
        input.className = "ui small icon input";

            let inputText = document.createElement('input');
            inputText.style.textTransform = "capitalize";
            inputText.placeholder = "Enter your name";

            let inputIcon = document.createElement('i');
            inputIcon.className = "inverted circular user outline icon";

        let button = document.createElement('div');
        button.className = "ui green button";
        button.innerHTML = "Add"
        button.onclick = function () {
            if (inputText.value != "") {
                onButtonClick(doc, inputText.value);
                inputText.value = "";
            }
            else
                showAlert();
        }

    card.append(header);
    card.append(price);
    card.append(description);
    card.append(rightContent);

    rightContent.append(input);
    input.append(inputText);
    input.appendChild(inputIcon);
    rightContent.append(button);

    cardsSegmentId.append(card);
}


// to retrieve data from firestore
database.collection("subjectCards")
    .onSnapshot(function (snapshot) {
        snapshot.docChanges().forEach(function (change) {
            if (change.type === "added") {
                listCards(change.doc);
                console.log("added", change.doc.data());
            }
            if (change.type === "modified") {
                console.log("Modified", change.doc.data());
            }
            if (change.type === "removed") {
                console.log("Removed ", change.doc.data());
                let div = cardsSegmentId.querySelector('[data-id=' + change.doc.id + ']');
                cardsSegmentId.removeChild(div);
            }
        });
    });

