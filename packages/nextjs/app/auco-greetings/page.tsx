"use client";

import Link from "next/link";
import { useQuery } from "@tanstack/react-query";
import type { NextPage } from "next";
import { formatEther } from "viem";
import { Address } from "~~/components/scaffold-stark";

type Greeting = {
  id: string;
  greeting: string;
  greeting_setter: `0x${string}`;
  premium: boolean;
  value: number;
  timestamp: string;
};

const fetchGreetings = async () => {
  const data = await fetch("http://localhost:3001/api/events");
  return data.json();
};

const PonderGreetings: NextPage = () => {
  const { data: greetingsData } = useQuery({
    queryKey: ["greetings"],
    queryFn: fetchGreetings,
    refetchInterval: 2000,
  });

  console.log(greetingsData);

  return (
    <>
      <div className="flex items-center flex-col flex-grow pt-10">
        <div className="px-5 text-center">
          <h1 className="text-4xl font-bold">Auco</h1>
          <div>
            <p>
              This extension allows using{" "}
              <a
                target="_blank"
                href="https://www.npmjs.com/package/auco/"
                className="underline font-bold text-nowrap"
              >
                Auco
              </a>{" "}
              for event indexing on a SE-2 dapp.
            </p>
            <p>
              Auco is an open-source indexer for blockchain application
              backends.
            </p>
            <p>
              With Auco, you can rapidly build & deploy an API that serves
              custom data from smart contracts on Starknet.
            </p>
          </div>

          <div className="divider my-0" />
          <h2 className="text-3xl font-bold mt-4">Getting Started</h2>
          <div>
            <p>
              Then index events by adding code to{" "}
              <code className="italic bg-base-300 text-base font-bold max-w-full break-words break-all [word-spacing:-0.5rem] inline-block">
                packages / auco / src / auco.service.ts
              </code>
            </p>
            <p>
              Start the development Auco server running{" "}
              <code className="italic bg-base-300 text-base font-bold max-w-full break-words break-all [word-spacing:-0.5rem] inline-block">
                yarn auco:dev
              </code>
            </p>
            <p>
              Finally, query your data using the custom API in / packages / auco
              / index.ts based on your data
            </p>
            <p>
              You can find more information at{" "}
              <code className="italic bg-base-300 text-base font-bold max-w-full break-words break-all [word-spacing:-0.5rem] inline-block">
                packages / auco / README.md
              </code>{" "}
              or the{" "}
            </p>
          </div>
          <div className="divider my-0" />

          <h2 className="text-3xl font-bold mt-4">Greetings example</h2>

          <div>
            <p>
              Below you can see a list of greetings fetched from the Custom API
              we wrote in packages / auco / src / index.ts API.
            </p>
            <p>
              Add a greeting from the{" "}
              <Link href="/debug" passHref className="link">
                Debug Contracts
              </Link>{" "}
              tab, reload this page and the new greeting will appear here.
            </p>
          </div>
        </div>

        <div className="flex-grow bg-base-300 w-full mt-16 px-8 py-12">
          <h2 className="text-center text-4xl font-bold">Greetings</h2>
          {!greetingsData && (
            <div className="flex items-center flex-col flex-grow pt-12">
              <div className="loading loading-dots loading-md"></div>
            </div>
          )}
          {greetingsData && !greetingsData.events.length && (
            <div className="flex items-center flex-col flex-grow pt-4">
              <p className="text-center text-xl font-bold">
                No greetings found
              </p>
            </div>
          )}
          {greetingsData && greetingsData.events.length > 0 && (
            <div className="flex flex-col items-center">
              {greetingsData.events.map((greeting: Greeting) => (
                <div key={greeting.id} className="flex items-center space-x-2">
                  <p className="my-2 font-medium">{greeting.greeting}</p>
                  <p>from</p>
                  <Address address={greeting.greeting_setter} />
                  <p>at</p>
                  <p className="my-2 font-medium">{greeting.timestamp}</p>
                  {greeting.premium && (
                    <p className="my-2 font-medium">
                      {" "}
                      - Premium ({formatEther(BigInt(greeting.value))} STRK)
                    </p>
                  )}
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </>
  );
};

export default PonderGreetings;
